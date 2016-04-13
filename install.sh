#!/bin/sh
#this is tested on fresh 2016-03-18-raspbian-jessie-lite.img

#move to supper user
#sudo su

#move to home direcotry
#cd

#clone repo
#git clone https://github.com/catonrug/raspbian-icecast2-mpd-mpc.git
#cd raspbian-icecast2-mpd-mpc
#chmod +x install.sh
#./install.sh

#update the system
apt-get update -y && apt-get upgrade -y

#set up correct time zone
cp /usr/share/zoneinfo/Etc/GMT-2 /etc/localtime

#install music player daemon
apt-get install mpd -y

#put IP address into the variable
ipaddress=$(ifconfig | grep "inet.*cast" | sed "s/[: ]/\n/g" | grep -m1 "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+")

#set mpd configuration file. you can change 'hackme' password.
#make sure you type the same password as in icecast configuration
cat > /etc/mpd.conf << EOF
	music_directory         "/var/lib/mpd/music"
	playlist_directory      "/var/lib/mpd/playlists"
	db_file                 "/var/lib/mpd/tag_cache"
	log_file                "/var/log/mpd/mpd.log"
	pid_file                "/run/mpd/pid"
	state_file              "/var/lib/mpd/state"
	sticker_file            "/var/lib/mpd/sticker.sql"
	user                    "mpd"
	bind_to_address         "127.0.0.1"


input {
	plugin "curl"
}

audio_output {
	type                    "shout"
	name                    "Algorithm"
	description             "MPD stream on Raspberry Pi"
	host                    "$ipaddress"
	port                    "8000"
	mount                   "/mpd"
	password                "hackme"
	bitrate                 "128"
	format                  "44100:16:2"
	encoding                "mp3"
}

	filesystem_charset      "UTF-8"
	id3v1_encoding          "UTF-8"
EOF

#install music player controller
apt-get install mpc -y

#install samba share
apt-get install samba samba-common-bin -y

#set up samba share public share which will be available without any password 
cat > /etc/samba/smb.conf << EOF
#======================= Global Settings =========================
[global]
workgroup = WORKGROUP
security = share
map to guest = bad user
#======================= Share Definitions =======================
[music]
path = /var/lib/mpd/music
browsable =yes
writable = yes
guest ok = yes
read only = no
EOF

#any user from any system can write into this samba share
chmod -R 777 /var/lib/mpd/music
chmod -R g+s /var/lib/mpd/music
chmod g+w /var/lib/mpd/music /var/lib/mpd/playlists
chgrp audio /var/lib/mpd/music /var/lib/mpd/playlists

#restart sharing service
/etc/init.d/samba restart

#install icecast2 which will host our mp3 stream into the air
#you will be prompted to set up icecast server. shoose [yes]
apt-get install icecast2 -y

#modprobe
modprobe ipv6
sleep 1

#restart music player daemon service
/etc/init.d/mpd restart
sleep 1

/etc/init.d/icecast2 restart
sleep 1

#check output
mpc outputs
# Output 1 (RasPi MPD Stream) is enabled

#Check if the network is listening
netstat -ltpn

#clear playlist
mpc clear

#scan /var/lib/mpd/music for new songs
mpc update

#list all songs in /var/lib/mpd/music and add it to playlist
mpc ls | mpc add

#set shufle on
mpc random on

#set repeat on
mpc repeat on

#show playlist
mpc playlist

#start stream instantly
mpc play

#retry the service if not running every minute
echo "* * * * * root mpc play">> /etc/crontab

#auto refresh playlist at midnight
echo "00 00 * * * root mpc stop && mpc clear && mpc update && mpc ls | mpc add && mpc random on && mpc repeat on">> /etc/crontab

#restart sheduled task service
/etc/init.d/cron restart
