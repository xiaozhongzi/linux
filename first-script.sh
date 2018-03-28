#!/bin/bash
#Date:2018-03-25
#Version:0.01
#Author:ZhangPeng
echo "this is the first shell script"
echo "generate files"
for name in {1..100}.txt
do
    touch $name 
done 
echo "analyze documentation information"
file_num=`ls -la | grep "^-"|wc -l`
echo "the num of file is $file_num"
folder_num=`ls -la | grep "^d"|wc -l`
echo "the num of folder is $folder_num"
docu_size=`du -sh . | awk '{print $1}'`
echo "the size of documentation is $docu_size"
echo "backup files start..."
backup_date=`date | awk '{print $6$2$3}'`
backup_path=$backup_date$RANDOM
backup_name=$backup_path+tar.gz
mkdir /$backup_path
cp -r . /$backup_path
cd /
tar -czf $backup_name  /$backup_path
echo "backip files end"


exit 0
