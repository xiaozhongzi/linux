#!/bin/bash 
# this program is control DNS server
# Date:2018-05-20
# Version:2.0
# Author: Zhang Peng

INSTALL(){
echo "execute INSTALL function"
command -v named || yum -y install bind bind-utils   # detection dhcp modules,install dhcp modules  
echo "the dhcpd has been installed"
} 

RUN(){
echo "execute RUN function"
FWS=`systemctl status firewalld | grep Active | awk '{print $2}'`
#echo "FWS:$FWS"
if [ $FWS == "inactive" ]
then
	echo "firewalld is closed"
else
	echo "closed firewalld..."
	systemctl stop firewalld
	echo "the status of firewalld:"
	systemctl status firewalld | grep Active
fi


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
#before reboot,set dns service starting up
	systemctl enable named
	reboot
	else
	echo "ok,not reboot"
	fi 
fi

systemctl restart named
systemctl enable named  # dhcpd service starting up           

} 

DISPLAY(){
echo "execute DISPLAY function"
echo "dns version:"
named -v
read -p "input domain name or IP address for query: " DMN
host $DMN

#后期可以新增修改 /etc/resolve.conf功能

}

MODIFY(){
echo "execute MODIFY function"

cat <<EOF
which one operation u want to execute?
(MMF)Modify Mapping File
(MMC)Modify Main Configuration
EOF

read -p "choose operation MMF,MMC? " OP
case $OP in
MMF)
echo "run MMF"
read -p "please input domain name: " DOMAIN
read -p "please input IP address: " IPADDR
#L3DOMAIN= $(echo $DOMAIN | awk -F . '{print $1}')
#L3IPADDR= $(echo $IPADDR | awk -F . '{print $4}')
NEWDOMAIN=$DOMAIN.
#截取域名、IP地址部分信息
L3DOMAIN=${DOMAIN%%.*}
L3IPADDR=${IPADDR##*.}
#echo $L3IPADDR
#echo $L3DOMAIN
echo -e "$L3DOMAIN \tIN\tA\t $IPADDR " >> /var/named/fqnu.org
echo -e "$L3IPADDR \tIN\tPTR\t $NEWDOMAIN" >> /var/named/59.168.192
systemctl restart named
;;

MMC)
echo "run MMC..."
read -p "please input forward domain file name: " FDFN
read -p "please input reverse domain file name: " RDFN

##在特定文件夹下，生成特定文件，同时修改/etc/named.conf主配置文件

#touch /var/named/$FDFN
#$touch /var/named/$RDFN

cp /var/named/named.empty /var/named/$FDFN
cp /var/named/named.empty /var/named/$RDFN
chmod 644 /var/named/$FDFN
chmod 644 /var/named/$RDFN

###测试成功，后期可以将test替换成 /etc/named，再结合systemctl restart named
cat <<EOF >> /etc/named.conf
zone "$FDFN"{
	type master;
	file "$FDFN";
};

zone "$RDFN.in-addr.arpa"{
	type master;
	file "$RDFN";
};
EOF

;;

*)
echo "please input right options"
esac
}




 
ANALYSIS(){
echo "execute ANALYSIS function"
echo > /tmp/host-tmp
echo > /tmp/tmp/tmp
for IPTEST in {110..140}
do
host 192.168.59.$IPTEST  >> /tmp/host-tmp
done
grep -v "not found" /tmp/host-tmp | sort | uniq 

echo "fetch information:"
grep -v "not found" /tmp/host-tmp | sort | uniq > /tmp/tmptmp
awk -F . 'BEGIN {OFS="."}{print $4,$3,$2,$1,$6,$7,$8}' /tmp/tmptmp | sed 's/.arpa domain name pointer//'



}
SHOW(){
echo "execute SHOW DNS Status function"
systemctl status named | grep Active
journalctl -f | grep named
}

HINT(){
read -p "Press Enter to continue:"
} 
while true
do
clear
echo "********************************"
echo "1.Install DNS server:"
echo "2.Run DNS server:"
echo "3.Display DNS Information:"
echo "4.Modify the configuration files"
echo "5.Analysis domain "
echo "6.Show DNS status"
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
