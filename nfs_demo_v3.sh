#!/bin/bash
# shell name:nfs_demo_v3.sh
# this program for control nfs server
# Date:2018-11-26
# Version:3.0
# Author: zp




INSTALL(){
echo "execute INSTALL function"
echo "begin to check software"
(yum list | grep rpcbind) && (yum list | grep nfs-utils)
if [ $? -eq 0 ] 
then
	echo "rpcbind and nfs-utils have been installed"
else
	echo "begin to install rpcbind and nfs-utils"
	yum -y install rpcbind nfs-utils  
	echo "install success" 
fi

#yum -y install nfs-utils rpcbind  #install nfs modules 
} 

RUN(){
echo "execute RUN function"
systemctl stop firewalld.service   #close firewall
systemctl disable firewalld.service  # close firewall starting up
systemctl restart nfs  
systemctl enable nfs   #start nfs starting up           

} 

GENERATE(){
echo "execute GENERATE function"
for i in {1..5}
do
	echo $RANDOM >/var/cloud/FILE$RANDOM 
	
done
}

MODIFY(){
echo "nfs configuration:"
cat /etc/exports
echo "execute MODIFY function"
echo "/var/web/ 192.168.153.171(rw,sync)" >>/etc/exports
read -p "plese input u want share folder path:" FolderPath
mkdir -p $FolderPath 
read -p "the share folder who can access: " ACCESS_IP
read -p "the right of ACCESS_USER: " RIGHTS
echo "modify the nfs configuration...."
echo "$FolderPath $ACCESS_IP""($RIGHTS)" >>/etc/exports
echo "modify success"


#去除重复配置文件行
sort /etc/exports | uniq > /etc/exports
#配置生效
exportfs -r
} 
ANALYSIS(){
echo "execute ANALYSIS function"
du -sh /var/web/
du -sh /var/cloud/
echo "the num of files"
CLOUDNUM=$(ls -la /var/cloud/|grep "^-"|wc -l)
WEBNUM=$(ls -la /var/web|grep "^-"|wc -l )
echo $(($CLOUDNUM+$WEBNUM))
}
SHOW(){
echo "execute SHOW function"
echo "server IP addr is:"
ifconfig | grep inet | head -1 | awk '{print $2}'
echo "server status:"
nfsstat -s
echo "-----------------"
echo "client status:"
nfsstat -c
echo "server share file list:"
LOCAL_IP=$(hostname -I)
showmount -e $LOCAL_IP

}

HINT(){
read -p "Press Enter to continue:"
} 
while true
do
clear
echo "********************************"
echo "1.Install nfs server:"
echo "2.Run nfs server:"
echo "3.Generate share file:"
echo "4.Modify the configuration files"
echo "5.Analysis the NFS resources consumption "
echo "6.Show NFS status"
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

