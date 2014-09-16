-- Pure Data (Pd) external for remote-controlling the SoundScape Renderer (SSR)
-- Matthias Geier, Sept. 2014

local SsrClient = pd.Class:new():register("ssrclient")

-- XML parser from http://github.com/Phrogz/SLAXML
local SLAXML = require("slaxml")

function SsrClient:output_command()
    -- first part of command becomes the selector, the rest atoms
    self:outlet(1, self.command[1], {select(2, unpack(self.command))})
    self.command = {}
end

function SsrClient:backup_command()
    self.command_backup = {}
    for k, v in ipairs(self.command) do
        self.command_backup[k] = v
    end
end

function SsrClient:restore_command()
    self.command = {}
    for k, v in ipairs(self.command_backup) do
        self.command[k] = v
    end
end

local SELECTORS = {
    source = "src",
    reference = "ref",
    loudspeaker = "ls",
    transport = "transport",
    volume = "vol",
}

local ATTRIBUTES = {
    file = "file",
    port = "port",
    position = "pos",
    orientation = "azi",
}

-- init stuff and set up callbacks for XML parser
function SsrClient:initialize(name, atoms)
    self.inlets = 2
    self.outlets = 2
    self.buffer = {}
    self.elements = {}
    self.selector = nil
    self.src_id = nil
    self.command = {}

    -- TODO: set initial values before parser.parse()! Use wrapper function?

    self.parser = SLAXML:parser{
        startElement = function(name, nsURI, nsPrefix)
            if #self.elements == 0 and name ~= "update" then
                self:error("Root element must be <update>")
            elseif #self.elements == 1 then
                self.selector = SELECTORS[name]
                if name == "state" or name == "scene" then
                    -- do nothing?
                elseif self.selector == nil then
                    self:error("<" .. name .. "> not allowed here")
                end
            elseif #self.elements == 2 then
                assert false, "do we see this in Pd?"
                assert not self.command
                local attr = ATTRIBUTES[name]
                if attr then
                    table.insert(self.command, attr)
                elseif name == "state" or name == "scene" then
                    -- these strings don't become part of the message
                else
                    self:error("<" .. name .. "> not allowed here")
                end
            else
                self:error(name .. " is nested too deeply")
            end
            table.insert(self.elements, name)
        end,
        attribute = function(name, value, nsURI, nsPrefix)
            if name == "id" then
                self.src_id = tonumber(value)
            elseif name == "x" or name = "y" or name = "azimuth" then
                table.insert(self.command, tonumber(value))
            elseif name == "name" or name == "model" or name == "transport" then
                table.insert(self.command, name)
                table.insert(self.command, value)
            elseif name == "mute" or name == "fixed" then
                table.insert(self.command, name)
                if value == "true" or value == "1" then
                    table.insert(self.command, 1)
                elseif value == "false" or value == "0" then
                    table.insert(self.command, 0)
                else
                    self:error("Invalid value for mute: " .. value)
                end
            elseif name == "length" or name == "file_length" or
                   name == "level" then
                table.insert(self.command, name)
                table.insert(self.command, tonumber(value))
            elseif name == "volume" then
                table.insert(self.command, "vol")
                table.insert(self.command, tonumber(value))
            elseif name == "channel" then
                table.insert(self.command, "file_channel")
                table.insert(self.command, tonumber(value))
                -- TODO: self:output_command()
                table.insert(self.command, "file")
            elseif name == "output_level" then
                table.insert(self.command, "weights")
                for weight in value:gmatch("%S+") do
                    table.insert(self.command, tonumber(weight))
                end
            else
                self:error("Ignored attribute: " .. name .. " value: " .. value)
            end
            -- TODO: output command (except for "x")
        end,
        closeElement = function(name, nsURI)
            -- nothing
        end,
        text = function(text)
            if self.command[1] == "vol" then
                table.insert(self.command, tonumber(text))
            else
                table.insert(self.command, text)
            end
            self:output_command()
        end,
        comment = function(content)
            self:error("No comment allowed in XML string")
        end,
        pi = function(target, content)
            self:error("No processing instructions allowed in XML string")
        end,
    }
    return true
end

-- create XML string and send it out as list of ASCII numbers
function SsrClient:in_1(sel, atoms)
    local str = '<request>'
    if sel == "src" then
        str = str .. '<source id="' .. atoms[1] .. '"'
        local subcommand = atoms[2]
        if subcommand == "pos" then
            str = str .. '><position x="' .. atoms[3] ..
                                  '" y="' .. atoms[4] .. '"/></source>'
        elseif subcommand == "azi" then
            str = str .. '><orientation azimuth="' .. atoms[3] .. '"/></source>'
        elseif subcommand == "model" then
            str = str .. ' model="' .. atoms[3] .. '"/>'
        elseif subcommand == "mute" then
            local mute_str
            if atoms[3] == 0 then
                mute_str = "false"
            else
                mute_str = "true"
            end
            str = str .. ' mute="' .. mute_str .. '"/>'
        elseif subcommand == "gain" then
            self:error('"gain" not supported, use "vol"')
            return
        else
            self:error(subcommand .. " not supported")
            return
        end
    elseif sel == "ref" then
        str = str .. '<reference'
        local subcommand = atoms[1]
        if subcommand == "pos" then
            str = str .. '><position x="' .. atoms[2] ..
                                  '" y="' .. atoms[3] .. '"/></reference>'
        elseif subcommand == "azi" then
            str = str .. '><orientation azimuth="' .. atoms[2] ..
                  '"/></reference>'
        else
            self:error(subcommand .. " not supported")
            return
        end
    else
        self:error(sel .. " not (yet?) supported")
        return
    end
    str = str .. '</request>\0'  -- terminated with a binary zero
    self:outlet(2, "list", {str:byte(1, #str)})  -- convert to ASCII numbers
end

-- collect numbers in self.buffer. If a zero comes in, parse the whole string.
function SsrClient:in_2_float(f)
    if f == 0 then
        -- convert ASCII numbers to string
        local str = string.char(unpack(self.buffer))
        self.parser:parse(str, {stripWhitespace=true})
        self.buffer = {}
    else
        table.insert(self.buffer, f)
    end
end

-- convert list to individual floats
function SsrClient:in_2_list(atoms)
    for _, f in ipairs(atoms) do self:in_2_float(f) end
end

-- vim:filetype=lua:shiftwidth=4:softtabstop=-1:expandtab:textwidth=80
