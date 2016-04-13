#move to supper user
#sudo su

#cd

#clone repo
#git clone https://github.com/catonrug/raspbian-icecast2-mpd-mpc.git && cd raspbian-icecast2-mpd-mpc && chmod +x install.sh
#time ./install.sh

#update the system
apt-get update -y && apt-get upgrade -y

#install music player daemon
apt-get install mpd -y

ipaddress=$(ifconfig | grep "inet.*cast" | sed "s/[: ]/\n/g" | grep -m1 "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+")
cat > /etc/mpd.conf << EOF
music_directory         "/var/lib/mpd/music"
playlist_directory              "/var/lib/mpd/playlists"
db_file                 "/var/lib/mpd/tag_cache"
log_file                        "/var/log/mpd/mpd.log"
pid_file                        "/run/mpd/pid"
state_file                      "/var/lib/mpd/state"
sticker_file                   "/var/lib/mpd/sticker.sql"
user                            "mpd"
bind_to_address         "127.0.0.1"

input {
plugin "curl"
}

audio_output {
type            "shout"
name            "Algorithm"
description     "MPD stream on Raspberry Pi"
host            "$ipaddress"
port            "8000"
mount           "/mpd"
password        "hackme"
bitrate         "128"
format          "44100:16:2"
encoding        "mp3"
}

filesystem_charset              "UTF-8"
id3v1_encoding                  "UTF-8"
EOF

#install music player controller
apt-get install mpc -y

#copy icecast2 configuration 
cp -a icecast2 /etc
chmod 775 -R /etc/icecast2
chmod 660 /etc/icecast2/*
chmod 664 /etc/icecast2/admin/*
chmod 775 /etc/icecast2/web/*

#icecast is streaming software that puts music into the air
apt-get install icecast2 -y

#modprobe
modprobe ipv6

/etc/init.d/mpd restart
/etc/init.d/icecast2 restart

#check output
mpc outputs
# Output 1 (RasPi MPD Stream) is enabled

#Check if the network is listening
netstat -ltpn

#set permissions
chmod g+w /var/lib/mpd/music/ /var/lib/mpd/playlists/
chgrp audio /var/lib/mpd/music/ /var/lib/mpd/playlists/

#clear playlist
mpc clear

#scan /var/lib/mpd/music for new songs
mpc update

#list all songs in /var/lib/mpd/music and add it to playlist
mpc ls | mpc add

#show playlist
mpc playlist

#start stream
mpc play



