#!/bin/bash
#Date:2018-03-25
#Version:0.01
#Author:ZhangPeng
# this program is used to manage linux system
echo "this is the second shell script"
echo "generate some user"
#need root
if [ "$(id -u)" == "0" ]
then
echo "under root"
else
echo "u need root,please input root passwd"
su
fi
echo "add some user,passwd see user2passwd"
for USER_NAME in Ali Bob Carl Dave Eden Frank
do
	useradd $USER_NAME
	PASSWD=$RANDOM
	echo $USER_NAME >>user2passwd
	echo $PASSWD >>user2passwd
	echo $PASSWD | passwd --stdin $USER_NAME
done 
echo "software management"
rpm -qai > software_info
yum list > yum_list 
## 后续可以对上述两个文件进行相关信息提取



exit 0
