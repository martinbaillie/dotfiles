#!/bin/bash
#
# pbrisbin 2010
#
# http://pbrisbin.com:8080/bin/bashnotify
#
# modify the config after it's written!
#
# modified by KittyKatt (kittykatt@archlinux.us)
#                       (http://www.silverirc.com/kittykatt/) 2010
#
###

### utilities {{{
message() { echo 'usage: mpdnotify [start|stop|restart]'; exit 1; }

logger() { echo "$(date +'[ %d %b %Y %H:%M ]') :: $*" | tee -a "$log"; }

errorout() { logger "error: $*"; exit 1; }

# }}}

### write config file {{{
write_config() {
  if [ ! -f "$config" ]; then

    logger "NOTE: writing example config to $config..."
    logger "you should edit this file before starting the deamon"

    cat > "$config" << EOF
#!/bin/bash
#
# mpdnotify config - any valid bash is allowed, you
# only need to define handle_event() for the deamon
# to run properly
#
# \$mydir exists, and it's value is $mydir
#
###

###
#
# the actual handle_event() definition
#
# this is the only requirement for a valid config
#
###

# Constants
if [ "\$MPD_HOST" ]; then HOST="\$MPD_HOST"; else HOST="localhost"; fi
if [ "\$MPD_PORT" ]; then PORT="\$MPD_PORT"; else PORT="6600"; fi
MPD_TCP="/dev/tcp/\$HOST/\$PORT"
coverDir="\$HOME/.covers/"
tmpCover="/tmp/cover"
baseCover="/usr/share/mpd-libnotify/extras/base.png"
topCover="/usr/share/mpd-libnotify/extras/top.png"
noCover="/usr/share/mpd-libnotify/extras/NOCOVER.png"
myPID="\$HOME/.config/mpdnotify/pid"
mpdPID=\$(pidof mpd)
mpdArtist="Could not find Artist's name"
mpdTitle="Could not find Song's title"
mpdAlbum="Could not find Album's name"
mpcLength="Could not find Song's length"
mpcInfo="Cound not find Song's info"
showCover="true"
expireTime="1300"
#logout="true"



function mpd_sndcommmand() {
	# \$1 command
	exec 5<> \$MPD_TCP 2>/dev/null
	[[ \$? -gt 0 ]] && return 1
	echo \$1 >&5
	echo "close" >&5
	tmp=\$(cat <&5)
	exec 5>&-
	_ret=\$(head -n -1 <<< "\$tmp" | tail -n +2)
	return 0
}

function mpd_getinfo() {
	mpd_sndcommmand currentsong
	[[ \$? -gt 0 ]] && return 1
	_tmp=\$_ret
	mpdTitle=\$(grep "^Title: " <<< "\$_tmp" 2>/dev/null | sed "s/Title: //")
	mpdArtist=\$(grep "^Artist: " <<< "\$_tmp" 2>/dev/null | sed "s/Artist: //")
	mpdAlbum=\$(grep "^Album: " <<< "\$_tmp" 2>/dev/null | sed "s/Album: //")
	_songtime=\$(grep "^Time: " <<< "\$_tmp" 2>/dev/null | sed "s/Time: //" | cut -f 1 -d :)
	(( _mm=\$_songtime / 60 ))
	[[ \${#_mm} -eq 1 ]] && _mm="0\$_mm"
	(( _ss=\$_songtime - \$_mm * 60 ))
	[[ \${#_ss} -eq 1 ]] && _ss="0\$_ss"
	mpdLength="\$_mm:\$_ss"
	mpd_sndcommmand "status"
	_tmp=\$_ret
	mpdSongID=\$(grep "^songid: " <<< "\$_tmp" 2>/dev/null | sed "s/songid: //")
	mpdPlaylistL=\$(grep "^playlistlength: " <<< "\$_tmp" 2>/dev/null | sed "s/playlistlength: //")
}


function fetch_cover() {
  album=\$1
  file="\$coverDir/\$album"
  if [ ! -f "\$file" ] ; then
  	logger "\$file is not in covers... " >/dev/null
        url="http://www.albumart.org/index.php?srchkey=\${album// /+}&itempage=1&newsearch=1&searchindex=Music"
        cover_url=\$(curl -s "\$url" | awk -F 'src=' '/zoom-icon.jpg/ {print \$2}' | cut -d '"' -f 2 | head -n1)
        if [ -n "\$cover_url" ]; then
          logger "\$file retrieved and placed in covers directory..." >/dev/null
          wget -q -O "\$file" "\$cover_url"
        else
          logger "ERROR: Album cover not found online. Searched for: \${album// /+}" >/dev/null
        fi
  fi
}

handle_event() {
	if [[ -z \$mpdPID ]]; then
		echo "MPD is not currently running!"
		if [[ -f "\$myPID" ]]; then
			rm "\$myPID"
		fi
		exit
	else
		mpd_getinfo
		if [ "\${showCover}" = "true" ]; then
			if [ -f "/tmp/cover" ]; then rm /tmp/cover; fi
			if [ -f "\$coverDir/\$mpdAlbum" ]; then
				cp "\$coverDir/\$mpdAlbum" /tmp/cover
			else
				fetch_cover "\$mpdAlbum"
				if [ -f "\$coverDir/\$mpdAlbum" ]; then
					cp "\$coverDir/\$mpdAlbum" /tmp/cover
				else
					cp "\$noCover" /tmp/cover
				fi
			fi

			mogrify -resize 65x65! \$tmpCover
			convert \$baseCover "\$tmpCover" -geometry +4+3 -composite \$topCover -geometry +0+0 -composite "\$tmpCover"
			mpdAlbum=\$(echo "\$mpdAlbum" | sed -e 's/&/&amp;/')
			mpdTitle=\$(echo "\$mpdTitle" | sed -e 's/&/&amp;/')
			mpdArtist=\$(echo "\$mpdArtist" | sed -e 's/&/&amp;/')
			[[ "\${#mpdArtist}" -gt "25" ]] && mpdArtist=\$(echo "\${mpdArtist:0:25}...")
			[[ "\${#mpdTitle}" -gt "25" ]] && mpdTitle=\$(echo "\${mpdTitle:0:25}...")
			[[ "\${#mpdAlbum}" -gt "25" ]] && mpdAlbum=\$(echo "\${mpdAlbum:0:25}...")
			notify-send --expire-time="\${expireTime}" -i "\${tmpCover}" "MPD Notification" "\$(echo "<u>\${mpdTitle}</u>"; echo "By: <i>\${mpdArtist}</i>"; echo "From: <i>\${mpdAlbum}</i>"; echo "Length: <i>\${mpdLength}</i>"; echo "Position: <i>\${mpdSongID} / \${mpdPlaylistL}</i>")"

		else
			notify-send --expire-time="\${expireTime}" "MPD Notification" "\$(echo "<u>\${mpdTitle}</u>"; echo "By: <i>\${mpdArtist}</i>"; echo "From: <i>\${mpdAlbum}</i>"; echo "Length: <i>\${mpdLength}</i>"; echo "Position: <i>\${mpdSongID} / \${mpdPlaylistL}</i>")"
		fi



		if [ "\$logout" == "true" ]; then
			echo -e "\$mpdTitle \n \$mpdArtist \n \$mpdAlbum \n" > \$HOME/mpdout
		fi
	fi
}

# handle_event() {
#    mpdnotify &
# }

EOF

  exit 0

  fi

  . "$config"

  type -p handle_event || errorout 'handle_event() not defined, check your config'
}

# }}}

### start/stop deamon {{{
start_daemon() {
  [ -f "$pid" ] && errorout "file found at $pid, daemon already running?"

  # start listening in background
  ( while read -r; do
      handle_event
    done < <(mpc idleloop player) ) &

  echo $! > "$pid"
}

stop_daemon() {
  if [ -f "$pid" ]; then
    kill $(cat "$pid") || errorout 'error stopping daemon'

    rm "$pid"
  fi
}

# }}}

### constants


if [ "$XDG_CONFIG_HOME" ]; then
	mydir="$XDG_CONFIG_HOME/mpdnotify"
else
	mydir="$HOME/.config/mpdnotify"
fi

config="$mydir/config"

pid="$mydir/pid"

log="$mydir/log"

pipe="$mydir/pipe"

### run it

if [ ! -d "$mydir" ]; then
  mkdir -p "$mydir" || errorout "unable to create my dir $mydir"
fi

write_config

case "$1" in
  start)   start_daemon                       ;;
  stop)    stop_daemon                        ;;
  restart) stop_daemon; sleep 3; start_daemon ;;
  status)  handle_event			      ;;
  *)       message                            ;;
esac
