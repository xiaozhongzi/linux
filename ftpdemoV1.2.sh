#!/bin/bash 
# this program is control ftp server
# Date:2017-11-30
# Version:1.2
# Author: zp

INSTALL(){
echo "execute INSTALL function"
yum -y install vsftpd  #install nfs modules 
} 

RUN(){
echo "execute RUN function"
setenforce 0 #stop selinux
systemctl stop firewalld.service   #close firewall
systemctl restart vsftpd  
systemctl enable vsftpd   #start nfs starting up           

} 

GENERATE(){
echo "execute GENERATE function"
for i in {1..3}
do
	index=ftp$RANDOM
	file=zp$index
	useradd -s /sbin/nologin $index #create account
 	echo "123456" | passwd --stdin $index #set password
	echo -e "this is a share file from $index" > /home/$index/$file
	ls -la /home/$index/$file
	echo -e "modify attribute of $file "
	chmod 777 /home/$index/$file
	ls -la /home/$index/$file
done

}

MODIFY(){
echo "execute MODIFY function"
read -p "change ftpd_banner message? input YES or NO:" MESSAGE_CHOICE
if [ "$MESSAGE_CHOICE" == "YES" ]
then
read -p "please input ftp_banner message:" MESSAGE
sed -i '/^ftpd_banner/d' /etc/vsftpd/vsftpd.conf
echo -e "ftpd_banner=$MESSAGE" >> /etc/vsftpd/vsftpd.conf
elif [ "$MESSAGE_CHOICE" == "NO" ]
then
echo "OK,NO CHANGE"
else
echo "u input wrong,please input YES or NO"
fi

read -p "allow user can write? input YES or NO?" WRITE_CHOICE
if [ "$WRITE_CHOICE" == "YES" ] 
then
sed -i 's/write_enable=NO/write_enable=YES/g' /etc/vsftpd/vsftpd.conf
elif [ "$WRITE_CHOICE" == "NO" ]
then
sed -i 's/write_enable=YES/write_enable=NO/g' /etc/vsftpd/vsftpd.conf
else
echo "u input wrong,please input YES OR NO"
fi
systemctl restart vsftpd

} 
ANALYSIS(){
echo "execute ANALYSIS function"
read -p "please input which user u want analysis:" FTPUSER
du -sh /home/$FTPUSER
echo "the num of files:"
FTPNUM=$(ls -la /home/$FTPUSER|grep "^-"|wc -l )
echo $FTPNUM


}
SHOW(){
echo "execute SHOW function"
echo "server IP addr is:"
hostname -I
}

HINT(){
read -p "Press Enter to continue:"
} 
while true
do
clear
echo "********************************"
echo "1.Install vsftpd server:"
echo "2.Run vsftpd server:"
echo "3.Generate users:"
echo "4.Modify the configuration files"
echo "5.Analysis the vsftpd resources consumption "
echo "6.Show vsftpd status"
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
GENERATE
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
