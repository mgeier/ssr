## This file will be processed by automake (which is called by autogen.sh) to
## generate Makefile.in, which in turn will be processed by configure to
## generate Makefile.

## comments starting with a single # are copied to Makefile.in (and afterwards
## to Makefile), comments with ## are dropped.

## This file is only taken into account if --enable-app-bundle was chosen!
if ENABLE_APP_BUNDLE

dist_pkgdata_DATA = SSRIcon.icns
contentsdir = $(prefix)
contents_DATA = Info.plist
dist_bin_SCRIPTS = run-ssr.sh
dist_noinst_SCRIPTS = run-ssr.applescript

nobase_dist_dmgroot_DATA = .background/background.png Jack.webloc Getting-Started.txt

# this is done after installing the executable
install-exec-hook:
	cp -f `which ecasound` $(DESTDIR)$(bindir)
	chmod +w $(DESTDIR)$(bindir)/ecasound
	for exec in $(SSR_executables) ecasound; do \
		macdeployqt $(DESTDIR)$(contentsdir)/.. -executable=$(DESTDIR)$(bindir)/$$exec \
	; done
# macdeployqt installs some unnecessary dylibs/frameworks/plugins:
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libcrypto*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libdb*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libfreetype*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libglib*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libgthread*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libintl*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libjack*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libjpeg*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libpcre*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libpng*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libssl*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libtiff*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libwebp*.dylib
	$(RM) $(DESTDIR)$(contentsdir)/Frameworks/libzstd*.dylib
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtNetwork.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtPdf.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtQml.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtQmlModels.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtQuick.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtSvg.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/Frameworks/QtVirtualKeyboard.framework
	$(RM) -r $(DESTDIR)$(contentsdir)/PlugIns/iconengines
	$(RM) -r $(DESTDIR)$(contentsdir)/PlugIns/imageformats
	$(RM) -r $(DESTDIR)$(contentsdir)/PlugIns/platforminputcontexts
	$(RM) -r $(DESTDIR)$(contentsdir)/PlugIns/printsupport
	$(RM) -r $(DESTDIR)$(contentsdir)/PlugIns/styles
	$(RM) -r $(DESTDIR)$(contentsdir)/PlugIns/virtualkeyboard

	osacompile -o $(DESTDIR)$(bindir)/run-ssr.scpt \
		$(srcdir)/run-ssr.applescript

install-data-hook:
	-cd $(DESTDIR)$(dmgrootdir) && $(LN_S) /Applications


# create a DMG image
dmg:
	@test -d "$(dmgrootdir)" || ( echo; echo; \
		echo "MacOSX App-Bundle directory not found!"; \
		echo "run 'make install' first!"; echo; false )
	hdiutil create -ov -attach -format UDRW \
		-volname "SoundScape Renderer @PACKAGE_VERSION@" \
		-srcfolder "$(dmgrootdir)" \
		"$(top_builddir)/SSRTemp.dmg"
	osascript DMG-Layout.applescript
	hdiutil detach "/Volumes/SoundScape Renderer @PACKAGE_VERSION@"
	hdiutil convert -ov -format UDZO -imagekey zlib-level=9 \
		-o "$(top_builddir)/$(DMG_NAME)" \
		"$(top_builddir)/SSRTemp.dmg"
	$(RM) "$(top_builddir)/SSRTemp.dmg"
	$(RM) -r "$(dmgrootdir)"

.PHONY: dmg

endif
