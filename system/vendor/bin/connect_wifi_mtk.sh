#! /system/bin/sh

echo "$0 $@"
date +%H:%M:%S
echo "begin wifi connect"
echo 0 > /dev/wmtWifi
sleep 0.2
echo 1 > /dev/wmtWifi
sleep 0.5
ifconfig wlan0 up
temp_ip=0
SSID=''
#ps|grep wpa_supplicant
wpa_supplicant -iwlan0 -Dnl80211 -c/system/etc/wifi/wpa_supplicant.conf -O/data/misc/wifi/sockets &
sleep 0.5

#echo "wifi scan"
while true
do 
    wpa_cli -iwlan0 -p /data/misc/wifi/sockets scan
    sleep 1
    STATUS=`wpa_cli -iwlan0 -p /data/misc/wifi/sockets scan_result|grep $1`
	echo "wpa_cli -iwlan0 -p /data/misc/wifi/sockets scan_result|grep $1"
    #STATUS=`iw dev wlan0 scan|grep $1`
    echo $STATUS
    if [ -n "$STATUS" ];then
        TEMP_SSID=`echo $STATUS|cut -d ' ' -f 5`  
        #TEMP_SSID=`echo $STATUS|cut -d ':' -f 2| sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
        SSID=$TEMP_SSID
        temp_ip=`echo $TEMP_SSID|cut -d \- -f 2`   
        #echo temp_ip=$temp_ip
        break;
    fi

    if [ -z "$SSID" ]; then
        echo Not find SSID
    fi
done

temp_ip_i=$(($temp_ip+10))
IP="192.168.$temp_ip_i.10"
S_IP="192.168.$temp_ip_i.1"

NETID=0

#echo "remove_network"
wpa_cli -iwlan0 -p /data/misc/wifi/sockets remove_network $NETID 2>/dev/null

echo "wpa_cli -iwlan0 -p /data/misc/wifi/sockets remove_network $NETID"
wpa_cli -iwlan0 -p /data/misc/wifi/sockets remove_network $NETID 
echo "wpa_cli -iwlan0 -p /data/misc/wifi/sockets add_network"
NETID=`wpa_cli -iwlan0 -p /data/misc/wifi/sockets add_network` 
#echo $NETID
echo -e wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETID ssid \'\"${SSID}\"\'
wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network ${NETID} ssid '"'${SSID}'"'
echo "wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETID key_mgmt NONE"
wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETID key_mgmt NONE 
echo "wpa_cli -iwlan0 -p /data/misc/wifi/sockets select_network $NETID"
wpa_cli -iwlan0 -p /data/misc/wifi/sockets select_network $NETID 
echo "wpa_cli -iwlan0 -p /data/misc/wifi/sockets enable_network $NETID"
wpa_cli -iwlan0 -p /data/misc/wifi/sockets enable_network $NETID
sleep 0.5

i=0
STATUS=`wpa_cli -iwlan0 -p /data/misc/wifi/sockets status | grep 'wpa_state=COMPLETED'`
while [ -z "$STATUS" ] && [ "$i" != "3" ];do
    i=$(($i+1))
    echo "try to enable network $i"
    #echo "STATUS = $STATUS"
    sleep 0.5
    STATUS=`wpa_cli -iwlan0 -p /data/misc/wifi/sockets status | grep 'wpa_state=COMPLETED'`
done
if [ -z "$STATUS" ]; then
    echo "enable_network failed"
    exit 0
else
    echo "enable_network success"
fi

#echo get ip...
echo set ip=$IP
ifconfig wlan0 $IP netmask 255.255.255.0
#dhcptool wlan0
TIP=`ifconfig wlan0|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'|cut -d '.' -f 3`
#echo $IP
i=0
while [  -z "$TIP" ] && [ "$i" != "3" ];do
	echo "try grep '192.168' $i"
	sleep 0.2
	TIP=`ifconfig wlan0|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'|cut -d '.' -f 3`
	i=$(($i+1))
done

#ping -c 1 $S_IP
#date +%H:%M:%S

if [ -z "$TIP" ] ; then
	echo "not connet to ssid $SSID"
    exit 0
else
	echo "Have conneted to ssid $SSID $IP"
fi
#done
exit $temp_ip


