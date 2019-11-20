/******************************************************************************
 * Copyright © 2019 SSR Contributors                                          *
 *                                                                            *
 * This file is part of the SoundScape Renderer (SSR).                        *
 *                                                                            *
 * The SSR is free software:  you can redistribute it and/or modify it  under *
 * the terms of the  GNU  General  Public  License  as published by the  Free *
 * Software Foundation, either version 3 of the License,  or (at your option) *
 * any later version.                                                         *
 *                                                                            *
 * The SSR is distributed in the hope that it will be useful, but WITHOUT ANY *
 * WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
 * FOR A PARTICULAR PURPOSE.                                                  *
 * See the GNU General Public License for more details.                       *
 *                                                                            *
 * You should  have received a copy  of the GNU General Public License  along *
 * with this program.  If not, see <http://www.gnu.org/licenses/>.            *
 *                                                                            *
 * The SSR is a tool  for  real-time  spatial audio reproduction  providing a *
 * variety of rendering algorithms.                                           *
 *                                                                            *
 * http://spatialaudio.net/ssr                           ssr@spatialaudio.net *
 ******************************************************************************/

/// @file
/// Renderer that passes all source signals through to its outputs.

#ifndef SSR_PASSTHROUGHRENDERER_H
#define SSR_PASSTHROUGHRENDERER_H

#include "rendererbase.h"

namespace ssr
{

class PassthroughRenderer : public RendererBase<PassthroughRenderer>
{
private:
  using _base = RendererBase<PassthroughRenderer>;

public:
  static const char* name() { return "Pass-Through-Renderer"; }

  class Source;
  class Output;
  class RenderFunction;

  explicit PassthroughRenderer(const apf::parameter_map& params)
    : _base(params)
  {
    this->_show_head = false;
  }

  void load_reproduction_setup() {
    // Nothing to be done here
  }

  APF_PROCESS(PassthroughRenderer, _base)
  {
    _process_list(_source_list);
  }
};

class PassthroughRenderer::Source : public _base::Source
{
public:
  Source(const Params& p);
  ~Source();

private:
  Output* _output;
};

class PassthroughRenderer::Output : public _base::Output
{
public:
  struct Params : _base::Output::Params
  {
    Source* source;
  };

  Output(const Params& p)
    : _base::Output(p)
    , _source(p.source)
  {}

  APF_PROCESS(Output, _base::Output)
  {
    assert(_source);
    std::copy(_source->begin(), _source->end(), this->buffer.begin());
  }

private:
  Source* _source;
};

PassthroughRenderer::Source::Source(const Params& p)
  : _base::Source(p)
{
  auto params = Output::Params();
  params.source = this;
  const std::string prefix = this->parent.params.get(
      "system_output_prefix", "");
  if (prefix != "")
  {
    SSR_WARNING("TODO: Connect to " << prefix << "?");
    //params.set("connect-to", prefix + "???");
  }
  _output = this->parent.add(params);
}

PassthroughRenderer::Source::~Source()
{
  if (_output)
  {
    this->parent.rem(_output);
  }
}

}  // namespace ssr

#endif
