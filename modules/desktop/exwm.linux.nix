{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.desktop;
  theme = config.modules.theme;
  secrets = config.secrets;
in
{
  config = mkIf (cfg.wm == "exwm") {
    services.xserver = {
      enable = true;
      updateDbusEnvironment = true;
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };
      layout = "au";
      enableCtrlAltBackspace = true;
      dpi = cfg.dpi;

      windowManager.session =
        let
          # Allow for per-host injected desktop-related Emacs configuration.
          extraConfig = pkgs.writeText "emacs-extra-config" ''
            (setq mb/system-settings
              '((desktop/dpi . ${(toString cfg.dpi)})
                (desktop/hidpi . ${if cfg.hidpi then "t" else "nil"})))
          '';
        in
        singleton {
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
            user = config.user.name;
            extraConfig = ''
              font-size = 1.0em
              font = "Iosevka"
              password-background-color = "${theme.colours.bg}"
              window-color = "${theme.colours.bgalt}"
              border-color = "${theme.colours.magenta}"
              background-color = "${theme.colours.bgalt}"
              text-color = "${theme.colours.fg}"
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
          user = config.user.name;
        };

        sessionCommands = "${pkgs.xorg.xset}/bin/xset r rate 190 50";
      };
    };

    # Hide the cursor when typing.
    services.xbanish.enable = true;

    home.services = {
      # Compositor.
      picom = {
        enable = true;
        fade = true;
        fadeDelta = 1;
        fadeSteps = [ 1.0e-2 1.2e-2 ];
      };

      # Screenshotting.
      flameshot.enable = true;

      # Screen locking.
      screen-locker = {
        enable = true;
        lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
        inactiveInterval = 20;
      };

      # Bar.
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
            background =
              let stripHash = (s: builtins.substring 1 (-1) s);
              in "#F2${stripHash theme.colours.bg}"; # 95% Alpha transparency.
            foreground = "${theme.colours.fg}";
            enable-ipc = true;
            width = "100%";
            fixed-center = true;
            cursor-click = "pointer";
            cursor-scroll = "ns-resize";
          };
          "module/exwm" = {
            type = "custom/ipc";
            hook-0 = ''
              ${pkgs.emacs}/bin/emacsclient -e "(mb/polybar-exwm-workspace)" | ${pkgs.gnused}/bin/sed -e 's/^"//' -e 's/"$//'
            '';
            initial = 1;
            format-underline = "${theme.colours.blue}";
          };
          "module/exwm-title" = {
            type = "custom/ipc";
            hook-0 = ''
              ${pkgs.emacs}/bin/emacsclient -e "(mb/polybar-exwm-title)" | ${pkgs.gnused}/bin/sed -e 's/^"//' -e 's/"$//'
            '';
            format-foreground = "${theme.colours.fg}";
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
            format-charging-foreground = "${theme.colours.green}";
            format-discharging = "<ramp-capacity> <label-discharging>";
            format-discharging-foreground = "${theme.colours.green}";
            format-full = "<label-full>";
            format-full-foreground = "${theme.colours.green}";
            label-charging = "%percentage%% ";
            label-discharging = "%percentage%% ";
            label-discharging-foreground = "${theme.colours.green}";
            label-full = "  %percentage%% ";
            ramp-capacity-0 = " ";
            ramp-capacity-0-foreground = "${theme.colours.red}";
            ramp-capacity-1 = " ";
            ramp-capacity-1-foreground = "${theme.colours.orange}";
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
          "module/weather" =
            let
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

                KEY="${secrets.openweathermap_api_key}"
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
            in
            {
              type = "custom/script";
              exec = "${polybarWeather}/bin/polybar-weather";
              label =
                "%{A1:${pkgs.xdg_utils}/bin/xdg-open https\\://openweathermap.org/city/2147714:}%output%%{A}";
            };
        };
      };
    };

    # Xorg related packages.
    user.packages = with pkgs; [
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
}
