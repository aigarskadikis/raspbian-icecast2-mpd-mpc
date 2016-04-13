#move to supper user
#sudo su

#clone repo
#git clone https://github.com/catonrug/raspbian-icecast2-mpd-mpc.git && cd raspbian-icecast2-mpd-mpc && chmod +x install.sh
#time ./install.sh

#update the system
apt-get update -y && apt-get upgrade -y

#copy Media Player Control configuration
cp mpd.conf /etc
#make sure permissions are ok
chmod 640 /etc/mpd.conf
#change password
sed -i "s/F2crCrRQ/newpassword/g" /etc/mpd.conf

#create direcotry for icecast2 configuration
mkdir -p /etc/icecast2
#copy icecast configuration
cp icecast.xml /etc/icecast2
chmod 660 /etc/icecast2/icecast.xml
#change password
sed -i "s/F2crCrRQ/newpassword/g" /etc/icecast2/icecast.xml

#install music player daemon
apt-get install mpd -y

#install music player controller
apt-get install mpc -y

#icecast is streaming software that puts music into the air
apt-get install icecast2 -y

#modprobe
modprobe ipv6

/etc/init.d/mpd restart

#check output
mpc outputs
# Output 1 (RasPi MPD Stream) is enabled

#Check if the network is listening
netstat -ltpn

#set permissions
chmod g+w /var/lib/mpd/music/ /var/lib/mpd/playlists/
chgrp audio /var/lib/mpd/music/ /var/lib/mpd/playlists/


