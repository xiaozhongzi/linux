#!/bin/bash 
# this program is control DHCP server
# Date:2018-05-27
# Version:2.0
# Author: Zhang Peng

INSTALL(){
echo "execute INSTALL function"
command -v dhcpd || yum -y install dhcp  # detection dhcp modules,install dhcp modules 
echo "the dhcpd has been installed"
} 

RUN(){
echo "execute RUN function"
SeStatus=$(getenforce)
if [ $SeStatus == "Disabled" ] 
then 
echo "no selinux policy is loaded"
else
echo "the selinux status is $SeStatus,And begin to change..."
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
echo "change succeed, need reboot to take effort"
read -p "do u want reboot? yes or no: " REBOOT
	if [ $REBOOT == "yes" ]
	then
	echo "begin reboot..."
	systemctl enable dhcpd
	reboot
	else
	echo "ok,not reboot"
	fi 
fi
echo "restart dhcp server..."
systemctl restart dhcpd 
systemctl status dhcpd | grep Active
systemctl enable dhcpd   # dhcpd service starting up           

} 

DISPLAY(){
echo "execute DISPLAY function"
echo "dhcp version:"
dhcpd --version
echo "test dhcpd configuration file:"
dhcpd -t
echo "test dhcpd leases file :"
dhcpd -T


}

MODIFY(){
echo "execute MODIFY function"

######## modify the first parameter ###################
read -p "change default-lease-time ? input YES or NO: " MESSAGE_CHOICE
if [ "$MESSAGE_CHOICE" == "YES" ]
then
read -p "please input default-lease-time:" MESSAGE
sed -i "/^default-lease-time/c default-lease-time $MESSAGE;" /etc/dhcp/dhcpd.conf
#sed -i '/^default-lease-time/d' /etc/dhcp/dhcpd.conf
#sed -i "/^max-lease-time/i default-lease-time $MESSAGE;" /etc/dhcp/dhcpd.conf
#用下面的方法也行
#sed -i "/^default-lease-time/c default-lease-time $MESSAGE;/" /etc/dhcp/dhcpd.conf
elif [ "$MESSAGE_CHOICE" == "NO" ]
then
echo "OK,NO CHANGE"
else
echo "u input wrong,please input YES or NO"
fi
######## modify the second parameter ###################
read -p "change max-lease-time ? input YES or NO: " MLT_CHOICE
if [ "$MLT_CHOICE" == "YES" ]
then
read -p "please input max-lease-time:" MLT_MESSAGE
sed -i '/^max-lease-time/d' /etc/dhcp/dhcpd.conf
sed -i "/^default-lease-time/a max-lease-time $MLT_MESSAGE;" /etc/dhcp/dhcpd.conf
elif [ "$MLT_CHOICE" == "NO" ]
then
echo "OK,NO CHANGE"
else
echo "u input wrong,please input YES or NO"
fi

######## modify the third parameter ###################
read -p "change range IP  ? input YES or NO: " IP_CHOICE
if [ "$IP_CHOICE" == "YES" ]
then
read -p "please input Start IP address:" START_IP
read -p "please input Destination IP address:" DESTINATION_IP

sed -i '/range/d' /etc/dhcp/dhcpd.conf
sed -i "/^subnet/a  range $START_IP $DESTINATION_IP;" /etc/dhcp/dhcpd.conf
elif [ "$IP_CHOICE" == "NO" ]
then
echo "OK,NO CHANGE"
else
echo "u input wrong,please input YES or NO"
fi
echo "restart dhcp server..."
systemctl restart dhcpd
systemctl status dhcpd | grep Active

} 
ANALYSIS(){
echo "execute ANALYSIS function"
echo "configuration ip range: "
cat /etc/dhcp/dhcpd.conf | grep range

echo "assign IP resource:"
cat /var/lib/dhcpd/dhcpd.leases | awk '/^lease/{print $2}' | sort | uniq

read -p "please input IP address to query: " IP
grep -A 8  $IP  /var/lib/dhcpd/dhcpd.leases



}
SHOW(){
echo "execute SHOW DCHP Status function"
echo "server IP addr is:"
hostname -I
systemctl status dhcpd | grep Active
echo "begin to capture signals of dhcp server... "
journalctl -f | grep dhcpd

#tail -f /var/log/messages
#同样可以捕获ssh相关信号信息 journalctl -f | grep ssh

}

HINT(){
read -p "Press Enter to continue:"
} 
while true
do
clear
echo "********************************"
echo "1.Install dhcpd server:"
echo "2.Run dhcpd server:"
echo "3.Display DHCP Information:"
echo "4.Modify the configuration files"
echo "5.Analysis IP Assign "
echo "6.Show DHCP status"
echo "7.Exit Script:"
echo "********************************"
read -p "please select a function(1-7):" U_SELECT
case $U_SELECT in
	1)
INSTALL
HINT
;;
	2)
RUN
HINT
;;
	3)
DISPLAY
HINT
;;
	4)
MODIFY
HINT
;;
	5)
ANALYSIS
HINT
;;
	6)
SHOW
HINT
;;
	7)
exit
;;
	*)
read -p "Please Select 1-7,Press Enter to continue:"
esac
done
