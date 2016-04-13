#sudo su
#cd

#clone repo
#git clone https://github.com/catonrug/raspbian-icecast2-mpd-mpc.git && cd raspbian-icecast2-mpd-mpc && chmod +x install.sh
#time ./install.sh

#update the system
apt-get update -y && apt-get upgrade -y

cp /usr/share/zoneinfo/Etc/GMT-2 /etc/localtime


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

apt-get install samba samba-common-bin -y

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

#set permissions
chmod -R 777 /var/lib/mpd/music
chmod -R g+s /var/lib/mpd/music
chmod g+w /var/lib/mpd/music /var/lib/mpd/playlists
chgrp audio /var/lib/mpd/music /var/lib/mpd/playlists

/etc/init.d/samba restart

#icecast is streaming software that puts music into the air
apt-get install icecast2 -y

#modprobe
modprobe ipv6
sleep 1

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

#set shufle on
mpc repeat on

#show playlist
mpc playlist

#start stream
mpc play

#retry the service if not running every minute
echo "* * * * * root mpc play">> /etc/crontab
echo "00 00 * * * root mpc stop && mpc clear && mpc update && mpc ls | mpc add && mpc random on && mpc repeat on">> /etc/crontab
/etc/init.d/cron restart


