{ config, lib, pkgs, ... }: {
  # Sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;

  # Fonts.
  fonts = {
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      emojione
      font-awesome
      iosevka
      noto-fonts
      weather-icons
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" "EmojiOne Color" ];
        monospace = [ "Iosevka" "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  # EXWM.
  services.xserver = {
    enable = true;
    updateDbusEnvironment = true;
    libinput = {
      enable = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
    layout = "au";
    enableCtrlAltBackspace = true;
    dpi = config.my.dpi;

    windowManager.session = let
      # Allow for per-system injected Emacs configuration.
      extraConfig = pkgs.writeText "emacs-extra-config" ''
        (setq mb/system-settings
          '((desktop/dpi . ${(toString config.my.dpi)})
            (desktop/hidpi . ${if config.my.hidpi then "t" else "nil"})))
      '';
    in lib.singleton {
      name = "exwm";
      start = ''
        # Ensure Emacs env is up-to-date.
        if type doom &>/dev/null; then
          rm -f $XDG_CONFIG_HOME/emacs/.local/env
          doom env
        fi
        # Launch a fullscreen DBused Emacs.
        ${pkgs.dbus.dbus-launch} --exit-with-session emacs -mm --fullscreen \
          -l "${extraConfig}"
      '';
    };

    displayManager = {
      lightdm = {
        enable = true;
        greeters.mini = {
          enable = true;
          user = config.my.username;
          extraConfig = ''
            font-size = 1.0em
            font = "Iosevka"
            password-background-color = "${config.theme.colours.bg}"
            window-color = "${config.theme.colours.bgalt}"
            border-color = "${config.theme.colours.magenta}"
            background-color = "${config.theme.colours.bgalt}"
            text-color = "${config.theme.colours.fg}"
            background-image = ""

            [greeter]
            show-password-label = false
            password-label-text = ""
            password-input-width = 30
            password-alignment = left
          '';
        };
      };

      autoLogin = {
        enable = true;
        user = config.my.username;
      };

      sessionCommands = "${pkgs.xlibs.xset}/bin/xset r rate 190 50";
    };
  };

  # Hide the cursor when typing.
  services.xbanish.enable = true;

  my = {
    home.services = {
      # Compositor.
      picom = {
        enable = true;
        fade = true;
        fadeDelta = 1;
        fadeSteps = [ (toString 1.0e-2) (toString 1.2e-2) ];
      };
      # Screenshotting.
      flameshot.enable = true;
      # Screen locking.
      screen-locker = {
        enable = true;
        lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
        inactiveInterval = 20;
      };
      polybar = {
        enable = true;
        script = ""; # Manage Polybar lifecycle from within Emacs/EXWM.
        package = pkgs.polybar.override { pulseSupport = true; };
        config = {
          settings = { screenchange-reload = true; };
          "bar/top" = {
            padding = 1;
            modules-left = "exwm";
            modules-center = "exwm-title";
            modules-right = "volume battery gladate syddate weather";
            font-0 = "Iosevka";
            font-1 = "file\\-icons:style=icons";
            font-2 = "all\\-the\\-icons:style=Regular";
            font-3 = "github\\-octicons:style=Regular";
            font-4 = "Weather Icons:style=Regular";
            font-5 = "FontAwesome";
            font-6 = "EmojiOne Color";
            font-7 = "Unifont";
            background = let stripHash = (s: builtins.substring 1 (-1) s);
            in "#F2${
              stripHash config.theme.colours.bg
            }"; # 95% Alpha transparency.
            foreground = "${config.theme.colours.fg}";
            enable-ipc = true;
            width = "100%";
            fixed-center = true;
            cursor-click = "pointer";
            cursor-scroll = "ns-resize";
          };
          "module/exwm" = {
            type = "custom/ipc";
            hook-0 = ''
              ${pkgs.emacsGcc}/bin/emacsclient -e "(mb/polybar-exwm-workspace)" | ${pkgs.gnused}/bin/sed -e 's/^"//' -e 's/"$//'
            '';
            initial = 1;
            format-underline = "${config.theme.colours.blue}";
          };
          "module/exwm-title" = {
            type = "custom/ipc";
            hook-0 = ''
              ${pkgs.emacsGcc}/bin/emacsclient -e "(mb/polybar-exwm-title)" | ${pkgs.gnused}/bin/sed -e 's/^"//' -e 's/"$//'
            '';
            format-foreground = "${config.theme.colours.fg}";
            initial = 1;
          };
          "module/volume" = {
            type = "internal/pulseaudio";
            format-volume = "<ramp-volume> <label-volume>";
            label-muted = "";
            ramp-volume-font = 6;
            ramp-volume-0 = "";
            ramp-volume-1 = "";
            ramp-volume-2 = "";
            click-right = "${pkgs.lxqt.pavucontrol-qt}/bin/pavucontrol-qt &";
          };
          "module/battery" = {
            type = "internal/battery";
            full-at = 95;
            format-charging = "<animation-charging> <label-charging>";
            format-charging-foreground = "${config.theme.colours.green}";
            format-discharging = "<ramp-capacity> <label-discharging>";
            format-discharging-foreground = "${config.theme.colours.green}";
            format-full = "<label-full>";
            format-full-foreground = "${config.theme.colours.green}";
            label-charging = "%percentage%% ";
            label-discharging = "%percentage%% ";
            label-discharging-foreground = "${config.theme.colours.green}";
            label-full = "  %percentage%% ";
            ramp-capacity-0 = " ";
            ramp-capacity-0-foreground = "${config.theme.colours.red}";
            ramp-capacity-1 = " ";
            ramp-capacity-1-foreground = "${config.theme.colours.orange}";
            ramp-capacity-2 = " ";
            ramp-capacity-3 = " ";
            ramp-capacity-4 = " ";
            animation-charging-0 = " ";
            animation-charging-1 = " ";
            animation-charging-2 = " ";
            animation-charging-3 = " ";
            animation-charging-4 = " ";
          };
          "module/syddate" = {
            type = "internal/date";
            time = "%H:%M";
            label = "SYD %time% ";
          };
          "module/gladate" = {
            type = "custom/script";
            exec = ''TZ=Europe/Glasgow ${pkgs.coreutils}/bin/date +"%H:%M"'';
            label = "%{T6}%{T-} GLA %output% ";
          };
          "module/weather" = let
            polybarWeather = pkgs.writeScriptBin "polybar-weather" ''
              get_icon() {
              	case $1 in
              	01d) icon="" ;;
              	01n) icon="" ;;
              	02d) icon="" ;;
              	02n) icon="" ;;
              	03*) icon="" ;;
              	04*) icon="" ;;
              	09d) icon="" ;;
              	09n) icon="" ;;
              	10d) icon="" ;;
              	10n) icon="" ;;
              	11d) icon="" ;;
              	11n) icon="" ;;
              	13d) icon="" ;;
              	13n) icon="" ;;
              	50d) icon="" ;;
              	50n) icon="" ;;
              	*) icon="" ;;
              	esac

              	echo $icon
              }

              KEY="${config.my.secrets.openweathermap_api_key}"
              CITY="2147714" # Erko
              UNITS="metric"
              SYMBOL="°C"
              API="https://api.openweathermap.org/data/2.5"
              CITY_PARAM="id=$CITY"
              CURL=${pkgs.curl}/bin/curl
              JQ=${pkgs.jq}/bin/jq
              CUT=${pkgs.coreutils}/bin/cut
              weather=$($CURL -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
              forecast=$($CURL -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
              if [ -n "$weather" ]; then
                weather_temp=$(echo "$weather" | $JQ ".main.temp" | $CUT -d "." -f 1)
                weather_icon=$(echo "$weather" | $JQ -r ".weather[0].icon")

                forecast_temp=$(echo "$forecast" | $JQ ".list[].main.temp" | $CUT -d "." -f 1)
                forecast_icon=$(echo "$forecast" | $JQ -r ".list[].weather[0].icon")

                if [ "$weather_temp" -gt "$forecast_temp" ]; then
                    trend=""
                elif [ "$forecast_temp" -gt "$weather_temp" ]; then
                    trend=""
                else
                    trend=""
                fi
                echo "%{T5}$(get_icon "$weather_icon")%{T-} $weather_temp$SYMBOL %{T5}$trend  $(get_icon "$forecast_icon")%{T-} $forecast_temp$SYMBOL"
              fi
            '';
          in {
            type = "custom/script";
            exec = "${polybarWeather}/bin/polybar-weather";
            label =
              "%{A1:${pkgs.xdg_utils}/bin/xdg-open https\\://openweathermap.org/city/2147714:}%output%%{A}";
          };
        };
      };
    };
    packages = with pkgs; [
      alsaUtils
      arandr
      feh
      gtk3
      i3lock-fancy
      xclip
      xorg.xdpyinfo
      xorg.xev
      xorg.xmodmap
    ];
  };

  # Sway
  # TODO: Extract EXWM/Sway into modules when rewriting for flakes.
  # For now, just disable Sway.
  # let
  #   # My default desktop apps and settings across all NixOS installs.
  #   swayEnv = ''
  #     # Disable HiDPI scaling for X apps.
  #     # https://wiki.archlinux.org/index.php/HiDPI#GUI_toolkits
  #     # export QT_AUTO_SCREEN_SCALE_FACTOR=0
  #     # export GDK_SCALE=-1

  #     # TODO: Only for VMWare
  #     # Needed to support VMWare in Sway.
  #     export WLR_NO_HARDWARE_CURSORS=1

  #     # Tell various things to handle Wayland better.
  #     export MOZ_ENABLE_WAYLAND=1
  #     export MOZ_DBUS_REMOTE=1
  #     export MOZ_USE_XINPUT2=1

  #     export _JAVA_AWT_WM_NONREPARENTING=1

  #     # export GDK_BACKEND=wayland
  #     # export BEMENU_BACKEND=wayland
  #     # export CLUTTER_BACKEND=wayland
  #     # export SDL_VIDEODRIVER=wayland
  #     # export XDG_SESSION_TYPE=wayland
  #     # export QT_QPA_PLATFORM=wayland
  #     # export QT_QPA_PLATFORMTHEME=qt5ct
  #     # export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

  #     # Prevent DBUS.Error.ServiceUnknown: org.a11y.Bus not provided.
  #     # https://github.com/NixOS/nixpkgs/issues/16327
  #     export NO_AT_BRIDGE=1
  #     export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/''${UID}/bus
  #   '';
  #   reloadSway = ''
  #     echo "Reloading sway"
  #     swaymsg -s \
  #     $(find /run/user/''${UID}/ \
  #       -name "sway-ipc.''${UID}.*.sock") \
  #     reload
  #   '';

  #   runOrRaise = pkgs.writeShellScript "run-or-raise" ''
  #     id=$1
  #     workspace=$2
  #     process=$3
  #     shift 3
  #     if [[ ! -n $(pidof -x $process) ]]; then
  #       swaymsg "workspace $workspace; exec $@";
  #     fi
  #     swaymsg "[class=$id] focus" || swaymsg "[app_id=$id] focus"
  #   '';
  #   striphash = (s: builtins.substring 1 (-1) s);
  # in {
  #   # Sound.
  #   sound.enable = true;
  #   hardware.pulseaudio.enable = true;
  #   nixpkgs.config.pulseaudio = true;

  #   # Fonts.
  #   fonts = {
  #     enableGhostscriptFonts = true;
  #     fonts = with pkgs; [ iosevka noto-fonts emojione font-awesome ];
  #     fontconfig = {
  #       enable = true;
  #       # hinting.autohint = true;
  #       # hinting.enable = true;
  #       defaultFonts = {
  #         emoji = [ "Noto Color Emoji" "EmojiOne Color" ];
  #         monospace = [ "Iosevka" "Noto Sans Mono" ];
  #         sansSerif = [ "Noto Sans" ];
  #         serif = [ "Noto Serif" ];
  #       };
  #     };
  #   };

  #   # Qt5 integration.
  #   qt5 = {
  #     enable = true;
  #     platformTheme = "gtk2";
  #     style = "gtk2";
  #   };

  #   # Desktop programs.
  #   programs = {
  #     sway = {
  #       enable = true;
  #       wrapperFeatures.gtk = true;
  #       extraPackages = with pkgs; [
  #         gebaar-libinput # libinput gestures utility.
  #         grim # Screen image capture.
  #         imv # Image viewer.
  #         libnl # Waybar wifi.
  #         libpulseaudio # Waybar audio.
  #         libnotify # Notification libraries.
  #         mako # Notification daemon.
  #         qt5.qtwayland # QT compatibility.
  #         slurp # Screen area selection tool for Wayland.
  #         swayidle # Idle timeouts and triggers (screen locking, etc.).
  #         swaylock # Lock Wayland sessions.
  #         termite # Wayland-native terminal emulator.
  #         waybar # Polybar-alike bar for Wayland.
  #         waypipe # Network transparency for Wayland.
  #         wev # Wayland xev.
  #         wf-recorder # Wayland screen recorder.
  #         wl-clipboard # Wayland clipboard utilities.
  #         xdg_utils # `xdg-open` etc.
  #         xwayland # X compatibility.
  #         pcmanfm # Wayland friendly file browser.

  #         # TTY Sway start helper.
  #         (writeShellScriptBin "startsway" ''
  #                     ${swayEnv}

  #           	  dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY
  #                     systemctl --user import-environment
  #                     exec systemctl --user start sway.service
  #                   '')

  #         # Wofi (Rofi for Wayland).
  #         (writeShellScriptBin "wofi" ''
  #           exec ${wofi}/bin/wofi -t termite -W 30 -H 300 -b -n "$@"
  #         '')
  #         wofi
  #       ];
  #       extraSessionCommands = "${swayEnv}";
  #     };
  #   };

  #   # Desktop services.
  #   # Blue light filtering.
  #   # TODO: Not on VMWare VM.
  #   # services.redshift = {
  #   #   enable = true;
  #   #   temperature = {
  #   #     day = 6500;
  #   #     night = 2300;
  #   #   };
  #   #   # Use Wayland roots package.
  #   #   package = pkgs.redshift-wlr;
  #   # };

  #   systemd.user = {
  #     targets.sway-session = {
  #       description = pkgs.sway.meta.description;
  #       bindsTo = [ "graphical-session.target" ];
  #       wants = [ "graphical-session-pre.target" ];
  #       after = [ "graphical-session-pre.target" ];
  #     };

  #     services = {
  #       sway = {
  #         description = pkgs.sway.meta.description;
  #         bindsTo = [ "graphical-session.target" ];
  #         wants = [ "graphical-session-pre.target" ];
  #         after = [ "graphical-session-pre.target" ];
  #         # Explicitly unset PATH here to be later set by the startsway helper.
  #         environment.PATH = lib.mkForce null;
  #         serviceConfig = {
  #           Type = "simple";
  #           ExecStart = "${pkgs.sway}/bin/sway";
  #           Restart = "on-failure";
  #           RestartSec = 1;
  #           TimeoutStopSec = 10;
  #         };
  #       };

  #       waybar = {
  #         description = pkgs.waybar.meta.description;
  #         partOf = [ "graphical-session.target" ];
  #         wantedBy = [ "sway-session.target" ];
  #         serviceConfig = { ExecStart = "${pkgs.waybar}/bin/waybar"; };
  #       };

  #       mako = {
  #         description = pkgs.mako.meta.description;
  #         partOf = [ "graphical-session.target" ];
  #         wantedBy = [ "sway-session.target" ];
  #         serviceConfig = {
  #           Type = "dbus";
  #           BusName = "org.freedesktop.Notifications";
  #           ExecStart = "${pkgs.mako}/bin/mako";
  #         };
  #       };

  #       swayidle = {
  #         description = pkgs.swayidle.meta.description;
  #         partOf = [ "graphical-session.target" ];
  #         wantedBy = [ "sway-session.target" ];
  #         serviceConfig = {
  #           ExecStart = ''
  #             ${pkgs.swayidle}/bin/swayidle -d -w \
  #               timeout 300  '${pkgs.swaylock}/bin/swaylock -f -c ${
  #                 stripHash config.theme.colours.bg
  #               }' \
  #               timeout 600 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
  #                     resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
  #               before-sleep '${pkgs.swaylock}/bin/swaylock -f -c ${
  #                 stripHash config.theme.colours.bg
  #               }'
  #           '';
  #         };
  #       };
  #     };
  #   };

  #   # Desktop configuration.
  #   my = {
  #     home.xdg.configFile = {
  #       # Sway configuration.
  #       "sway/config" = {
  #         text = ''
  #                     set $mod Mod4
  #                     set $left h
  #                     set $down j
  #                     set $up k
  #                     set $right l
  #                     set $term termite
  #                     set $fileman pcmanfm
  #                     set $editor ${runOrRaise} Emacs 1 emacs emacs
  #                     set $browser ${runOrRaise} firefox 2 firefox firefox
  #                     set $menu wofi --show run | xargs swaymsg exec
  #                     set $bg ${config.theme.colours.bg}
  #                     set $fg ${config.theme.colours.fg}
  #                     set $bgalt ${config.theme.colours.bgalt}
  #                     set $fgalt ${config.theme.colours.fgalt}
  #                     set $selection ${config.theme.colours.blue}
  #                     set $bright ${config.theme.colours.yellow}
  #                     set $urgent ${config.theme.colours.red}

  #                     # Output.
  #                     output * bg ~/.config/wallpaper fill
  #                     # VMWare Virtualised Display (MBP Retina).
  #                     # output Virtual-1 mode 2560x1600 scale 2
  #                     # VMWare Virtualised Display (MBP + External).
  #                     # output Virtual-1 mode 1920x1200 scale 1

  #                     # Input.
  #                     input "1:1:AT_Translated_Set_2_keyboard" {
  #                         xkb_layout us
  #                         # xkb_options altwin:swap_alt_win,ctrl:nocaps
  #                         xkb_options ctrl:nocaps
  #                         repeat_rate 70
  #                         repeat_delay 200
  #                     }

  #                     # ThinkPad touchpad.
  #                     input "2:7:SynPS/2_Synaptics_TouchPad" {
  #                         dwt enabled
  #                         tap enabled
  #                         natural_scroll enabled
  #                         middle_emulation enabled
  #                         accel_profile adaptive
  #                         pointer_accel 0.1
  #                     }

  #                     # VMWare Virtual Mouse to mimic MacBook touchpad.
  #                     input "2:5:ImPS/2_Generic_Wheel_Mouse" {
  #                         accel_profile adaptive
  #                         pointer_accel 0.6
  #                         scroll_factor 2
  #                     }

  #                     # Hide the cursor after 1 seconds.
  #           #seat seat0 hide_cursor 1000

  #                     # Idle inhibition.
  #                     for_window [app_id="firefox"] inhibit_idle fullscreen

  #                     # Float Tridactyl windows.
  #                     for_window [title="Tridactyl"] floating enable

  #                     # Show applications Xwayland or native Wayland status.
  #                     for_window [shell=".*"] title_format "%title :: %shell"

  #                     # Workspace assignment.
  #                     assign [class="Emacs"] 1
  #                     assign [app_id="firefox"] 2
  #                     assign [class="Slack"] 3
  #                     assign [class="zoom"] 4
  #                     assign [title="^.*Zoom.*$"] 4

  #                     # Borders.
  #                     for_window [class="^.*"] border pixel 1
  #                     default_border pixel 1
  #                     default_floating_border pixel 1
  #                     smart_gaps on
  #                     hide_edge_borders smart
  #                     gaps inner 0
  #                     gaps outer 0

  #                     # Colours       border  background   text    indicator child_border
  #                     client.focused $selection $selection $bg $bright $selection
  #                     client.focused_inactive $fgalt $fgalt $bgalt $fgalt $fgalt
  #                     client.unfocused $fgalt $bgalt $fgalt $bgalt $bgalt
  #                     client.urgent $urgent $urgent $bg $urgent $urgent

  #                     ### Key bindings
  #                     #
  #                     # Basics:
  #                     #
  #                     bindsym $mod+q kill
  #                     bindsym $mod+e exec $fileman
  #                     bindsym $mod+Space exec $menu
  #                     bindsym $mod+Return exec $editor
  #                     bindsym $mod+Shift+Return exec $browser
  #                     # Emacs is my editor and term; $term is just a backup.
  #                     bindsym $mod+Mod1+Return exec $term
  #                     bindsym $mod+Ctrl+q exec --no-startup-id 'swaylock -f -c ${
  #                       stripHash config.theme.colours.bg
  #                     }'

  #                     # Media keys
  #                     bindsym XF86PowerOff exec --no-startup-id 'swaylock -f -c ${
  #                       stripHash config.theme.colours.bg
  #                     }'
  #                     bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume 0 +3%
  #                     bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume 0 -3%
  #                     bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute 0 toggle
  #                     bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute 1 toggle
  #                     bindsym XF86MonBrightnessUp exec ${pkgs.light}/bin/light -A 8
  #                     bindsym XF86MonBrightnessDown exec ${pkgs.light}/bin/light -U 8
  #                     bindsym XF86Display exec swaymsg output eDP-1 toggle

  #                     bindsym Shift+Print exec grim -g "$(slurp)"
  #                     bindsym Print exec grim

  #                     # Drag/resize mouse1/2
  #                     floating_modifier $mod normal

  #                     # Reload the config
  #                     bindsym $mod+Backspace reload

  #                     # Exit sway (logs you out of your Wayland session)
  #                     bindsym $mod+Shift+Backspace exec swaynag -e bottom -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'
  #                     bindsym Ctrl+Alt+Backspace exec swaymsg exit

  #                     #
  #                     # Movement
  #                     #
  #                     # focus
  #                     bindsym $mod+$left focus left
  #                     bindsym $mod+$down focus down
  #                     bindsym $mod+$up focus up
  #                     bindsym $mod+$right focus right

  #                     # shift
  #                     bindsym $mod+Shift+$left move left
  #                     bindsym $mod+Shift+$down move down
  #                     bindsym $mod+Shift+$up move up
  #                     bindsym $mod+Shift+$right move right

  #                     #
  #                     # Workspaces:
  #                     #
  #                     # switch to workspace
  #                     bindsym $mod+1 workspace 1
  #                     bindsym $mod+2 workspace 2
  #                     bindsym $mod+3 workspace 3
  #                     bindsym $mod+4 workspace 4
  #                     bindsym $mod+5 workspace 5
  #                     bindsym $mod+6 workspace 6
  #                     bindsym $mod+7 workspace 7
  #                     bindsym $mod+8 workspace 8
  #                     bindsym $mod+9 workspace 9
  #                     bindsym $mod+0 workspace 10
  #                     bindsym $mod+bracketleft workspace prev
  #                     bindsym $mod+bracketright workspace next
  #                     bindsym $mod+Tab workspace back_and_forth
  #                     # bindsym $mod+Tab workspace next_on_output
  #                     # bindsym $mod+Shift+Tab workspace prev_on_output

  #                     # shift to workspace
  #                     bindsym $mod+Shift+1 move container to workspace 1
  #                     bindsym $mod+Shift+2 move container to workspace 2
  #                     bindsym $mod+Shift+3 move container to workspace 3
  #                     bindsym $mod+Shift+4 move container to workspace 4
  #                     bindsym $mod+Shift+5 move container to workspace 5
  #                     bindsym $mod+Shift+6 move container to workspace 6
  #                     bindsym $mod+Shift+7 move container to workspace 7
  #                     bindsym $mod+Shift+8 move container to workspace 8
  #                     bindsym $mod+Shift+9 move container to workspace 9
  #                     bindsym $mod+Shift+0 move container to workspace 10

  #                     # shift workspace to output
  #                     bindsym $mod+Shift+Ctrl+$left move workspace to output left
  #                     bindsym $mod+Shift+Ctrl+$down move workspace to output down
  #                     bindsym $mod+Shift+Ctrl+$up move workspace to output up
  #                     bindsym $mod+Shift+Ctrl+$right move workspace to output right

  #                     #
  #                     # Layout stuff:
  #                     #
  #                     bindsym $mod+Mod1+w layout tabbed
  #                     bindsym $mod+Mod1+e layout toggle split
  #                     bindsym $mod+Mod1+f fullscreen
  #                     bindsym $mod+Mod1+Space layout stacking
  #                     bindsym $mod+Shift+Space floating toggle

  #                     # swap floating/tiling focus
  #                     bindsym $mod+Ctrl+Space focus mode_toggle

  #                     #
  #                     # Scratchpad:
  #                     #
  #                     # Sway has a "scratchpad", which is a bag of holding for windows.
  #                     # You can send windows there and get them back later.
  #                     bindsym $mod+Mod1+minus move scratchpad
  #                     bindsym $mod+minus scratchpad show

  #                     #
  #                     # Resizing containers:
  #                     #
  #                     mode "resize" {
  #                         # left will shrink the containers width
  #                         # right will grow the containers width
  #                         # up will shrink the containers height
  #                         # down will grow the containers height
  #                         bindsym $left resize shrink width 10px
  #                         bindsym $down resize grow height 10px
  #                         bindsym $up resize shrink height 10px
  #                         bindsym $right resize grow width 10px

  #                         # return to default mode
  #                         bindsym Return mode "default"
  #                         bindsym Escape mode "default"
  #                     }
  #                     bindsym $mod+r mode "resize"

  #                     #
  #                     # Reach systemd target:
  #                     #
  #                     exec "systemctl --user import-environment; systemctl --user start sway-session.target"
  #                   '';
  #         onChange = "${reloadSway}";
  #       };

  #       # Sway-friendly shell environment.
  #       "zsh/rc.d/env.sway.zsh".text = ''
  #         ${swayEnv}
  #       '';

  #       # Waybar configuration.
  #       "waybar/config" = {
  #         text = builtins.toJSON ({
  #           layer = "top";
  #           modules-left = [ "sway/workspaces" ];
  #           modules-center = [ "sway/window" ];
  #           modules-right = [
  #             "cpu"
  #             "memory"
  #             "temperature"
  #             # "backlight"
  #             "pulseaudio"
  #             "network"
  #             "battery"
  #             "idle_inhibitor"
  #             "clock"
  #           ];

  #           "sway/window" = { max-length = 100; };
  #           "sway/workspaces" = {
  #             disable-scroll = true;
  #             all-outputs = true;
  #             format = "{icon}";
  #             format-icons = {
  #               "1" = "";
  #               "2" = "";
  #               "3" = "";
  #               "4" = "";
  #               "5" = "";
  #             };
  #           };

  #           idle_inhibitor = {
  #             format = "{icon}";
  #             format-icons = {
  #               activated = "";
  #               deactivated = "";
  #             };
  #           };

  #           network = {
  #             format-wifi = " {essid}";
  #             format-ethernet = "";
  #             format-disconnected = "";
  #             # "on-click": "nm-applet"
  #             tooltip-format-wifi = " {essid} ({signalStrength}%)";
  #             tooltip-format-ethernet = " {ipaddr}/{cidr} ";
  #             tooltip-format-disconnected = "";
  #           };

  #           pulseaudio = {
  #             format = "{icon} {volume}%";
  #             format-bluetooth = "{icon} {volume}%";
  #             format-icons = {
  #               headphones = "";
  #               handsfree = "";
  #               headset = "";
  #               phone = "";
  #               portable = "";
  #               car = "";
  #               default = [ "" "" "" ];
  #             };
  #             on-click = "${pkgs.lxqt.pavucontrol-qt}/bin/pavucontrol-qt";
  #           };

  #           cpu = { format = " {load}%"; };

  #           memory = { format = " {}%"; };

  #           temperature = {
  #             critical-threshold = 80;
  #             format-critical = " {temperatureC}°C";
  #             format = " {temperatureC}°C";
  #           };

  #           # backlight = {
  #           #   format = "{icon} {percent}%";
  #           #   format-icons = [ "" "" ];
  #           # };

  #           battery = {
  #             format = "{icon} {capacity}%";
  #             format-charging = " {capacity}%";
  #             format-icons = [ "" "" "" "" "" ];
  #             states = {
  #               warning = 15;
  #               critical = 5;
  #             };
  #           };

  #           clock = { format-alt = "{:%a, %d. %b  %H:%M}"; };
  #         });
  #         onChange = "systemctl --user restart waybar";
  #       };

  #       # Waybar style.
  #       "waybar/style.css" = {
  #         source = pkgs.substituteAll {
  #           src = <config/waybar/style.css>;
  #           inherit (config.theme.colours)
  #             bg bgalt fg blue red green orange magenta;
  #         };
  #         onChange = "systemctl --user restart waybar";
  #       };

  #       "wofi/style.css".source = pkgs.substituteAll {
  #         src = <config/wofi/style.css>;
  #         inherit (config.theme.colours)
  #           bg bgalt fg blue red green orange magenta;
  #       };

  #       "mako/config" = {
  #         text = ''
  #           text-color=${config.theme.colours.fg}
  #           background-color=${config.theme.colours.bg}
  #           border-color=${config.theme.colours.bgalt}
  #           progress-color=source ${config.theme.colours.green}
  #           border-size=3
  #           max-visible=3
  #           default-timeout=15000
  #           group-by=app-name
  #           sort=-priority
  #           icons=1
  #           icon-path=${config.theme.icons}
  #           [urgency=high]
  #           border-color=${config.theme.colours.red}
  #           ignore-timeout=1
  #           default-timeout=0
  #         '';
  #         onChange = "systemctl --user restart mako";
  #       };

  #       "termite/config".text = ''
  #         [options]
  #             resize_grip = false
  #             scroll_on_output = false
  #             scroll_on_keystroke = true
  #             audible_bell = false
  #             visible_bell = false
  #             mouse_autohide = true
  #             allow_bold = true
  #             dynamic_title = true
  #             urgent_on_bell = true
  #             clickable_url = true
  #             scrollback_lines = 100000
  #             search_wrap = true
  #             cursor_blink = off
  #             cursor_shape = ibeam
  #             font = Noto Sans Mono 9
  #       '';
  #     };
  #   };
  # }
  #
  # Autologin TTYs on Sway.
  # services.mingetty.autologinUser = config.my.username;
}
