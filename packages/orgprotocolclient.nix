{ lib, stdenv, pkgs, writeText }:

stdenv.mkDerivation rec {
  pname = "OrgProtocolClient";
  version = "1.0.0";

  phases = [ "installPhase" ];

  scpt = writeText "main.scpt" ''
    on open location this_URL
    	do shell script "PATH=/run/current-system/sw/bin:$PATH emacsclient -s ${builtins.getEnv "XDG_DATA_HOME"}/emacs/server \"" & this_URL & "\""
    	tell application "Emacs" to activate
    end open location
  '';

  plist = writeText "Info.plist" ''
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
       "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>CFBundleAllowMixedLocalizations</key>
        <true />
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleExecutable</key>
        <string>applet</string>
        <key>CFBundleIconFile</key>
        <string>applet</string>
        <key>CFBundleIdentifier</key>
        <string>com.apple.ScriptEditor.id.OrgProtocolClient</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>OrgProtocolClient</string>
        <key>CFBundleIconFile</key>
        <string>Emacs.icns</string>
        <key>CFBundleDocumentTypes</key>
        <array>
          <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
              <string>*</string>
            </array>
            <key>CFBundleTypeIconFile</key>
            <string>document.icns</string>
            <key>CFBundleTypeName</key>
            <string>All</string>
            <key>CFBundleTypeOSTypes</key>
            <array>
              <string>****</string>
            </array>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
          </dict>
        </array>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <key>CFBundleSignature</key>
        <string>aplt</string>
        <key>LSMinimumSystemVersionByArchitecture</key>
        <dict>
          <key>x86_64</key>
          <string>10.6</string>
        </dict>
        <key>LSRequiresCarbon</key>
        <true />
        <key>NSAppleEventsUsageDescription</key>
        <string>This script needs to control other applications to
        run.</string>
        <key>NSAppleMusicUsageDescription</key>
        <string>This script needs access to your music to run.</string>
        <key>NSCalendarsUsageDescription</key>
        <string>This script needs access to your calendars to
        run.</string>
        <key>NSCameraUsageDescription</key>
        <string>This script needs access to your camera to
        run.</string>
        <key>NSContactsUsageDescription</key>
        <string>This script needs access to your contacts to
        run.</string>
        <key>NSHomeKitUsageDescription</key>
        <string>This script needs access to your HomeKit Home to
        run.</string>
        <key>NSMicrophoneUsageDescription</key>
        <string>This script needs access to your microphone to
        run.</string>
        <key>NSPhotoLibraryUsageDescription</key>
        <string>This script needs access to your photos to
        run.</string>
        <key>NSRemindersUsageDescription</key>
        <string>This script needs access to your reminders to
        run.</string>
        <key>NSSiriUsageDescription</key>
        <string>This script needs access to Siri to run.</string>
        <key>NSSystemAdministrationUsageDescription</key>
        <string>This script needs access to administer this system to
        run.</string>
        <key>OSAAppletShowStartupScreen</key>
        <false />
        <key>WindowState</key>
        <dict>
          <key>bundleDividerCollapsed</key>
          <true />
          <key>bundlePositionOfDivider</key>
          <real>0.0</real>
          <key>dividerCollapsed</key>
          <false />
          <key>eventLogLevel</key>
          <integer>2</integer>
          <key>name</key>
          <string>ScriptWindowState</string>
          <key>positionOfDivider</key>
          <real>443</real>
          <key>savedFrame</key>
          <string>20 515 700 678 0 0 1920 1200</string>
          <key>selectedTab</key>
          <string>description</string>
        </dict>
        <key>CFBundleURLTypes</key>
        <array>
          <dict>
            <key>CFBundleURLName</key>
            <string>org-protocol handler</string>
            <key>CFBundleURLSchemes</key>
            <array>
              <string>org-protocol</string>
            </array>
          </dict>
        </array>
      </dict>
    </plist>
  '';

  installPhase = ''
    mkdir -p $out/Applications
    /usr/bin/osacompile -o $out/Applications/OrgProtocolClient.app ${scpt}
    cp ${pkgs.emacsGitNativeComp}/Applications/Emacs.app/Contents/Resources/{document,Emacs}.icns $out/Applications/OrgProtocolClient.app/Contents/Resources/
    cp -f ${plist} $out/Applications/OrgProtocolClient.app/Contents/Info.plist
  '';

  meta = with lib; {
    description = "Org Protocol Client macOS App";
    homepage = "https://www.gnu.org/software/emacs";
    maintainers = with maintainers; [ mbaillie ];
    platforms = platforms.darwin;
  };
}
