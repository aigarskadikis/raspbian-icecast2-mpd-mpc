#move to supper user
sudo su

#update the system
apt-get update -y && apt-get upgrade -y

#install music player daemon
apt-get install mpd -y

#install music player controller
apt-get install mpc -y

#icecast is streaming software that puts music into the air
apt-get install icecast2 -y

#modprobe
modprobe ipv6

/etc/mpd.conf

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
 name            "RasPi MPD Stream"
 description     "MPD stream on Raspberry Pi"
 host            "192.168.88.86"
 port            "8000"
 mount           "/mpd.mp3"
 password        "hackme"
 bitrate         "128"
 format          "44100:16:2"
 encoding        "mp3"
}
filesystem_charset              "UTF-8"
id3v1_encoding                  "UTF-8"


/etc/init.d/mpd restart


#check output
mpc outputs
# Output 1 (RasPi MPD Stream) is enabled

#Check if the network is listening
netstat -ltpn

#set permissions
chmod g+w /var/lib/mpd/music/ /var/lib/mpd/playlists/
chgrp audio /var/lib/mpd/music/ /var/lib/mpd/playlists/