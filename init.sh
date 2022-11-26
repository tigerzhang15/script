#!/bin/bash
#此脚本用来初始化centos7系列的系统

#变量
TIME=`date +%d%H%M%S`

#判断系统版本
if [ -e /etc/redhat-release ];then
    systemver=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
        if [ $systemver -ne 7 ];then
            exit 1  && echo "OS is not rhel7"
        else
            echo ""
        fi
else
    exit 2 && echo "ERROR: OS is not rhel"
fi

#配置软件源
if [ -d /etc/yum.repos.d ];then
    mkdir -p /backup/repobak
    cd /etc/yum.repos.d/
    for i in $(find  -name "CentOS*" | sed 's|\.\/||g')
    do 
        mv $i /backup/repobak/$i.$TIME
    done
    curl https://mirrors.cloud.tencent.com/repo/centos7_base.repo -o /etc/yum.repos.d/centos7_base.repo
    curl https://mirrors.cloud.tencent.com/repo/epel-7.repo -o /etc/yum.repos.d/epel-7.repo
    yum clean all
    yum makecache
else
    exit 3 && echo "ERROR: /etc/yum.repos.d not exist"
fi

#关闭防火墙
Fw_Status=$(systemctl list-unit-files | grep firewalld | awk '{print $2}')
if [ $Fw_Status = enabled ];then
	systemctl disable --now firewalld &> /dev/null
else
    echo "firewalld maybe already shutdown"
fi

#关闭selinux
grep 'SELINUX=enforcing' /etc/selinux/config  && sed -i.bak 's|\(SELINUX=\)enforcing|\1disabled|g' /etc/selinux/config

#优化grub2启动，系统故障排错需要
grep '/rhgb\ quiet' /boot/grub2/grub.cfg &&  sed -i.bak 's/rhgb\ quiet//g' /boot/grub2/grub.cfg
grep '/rhgb\ quiet' /etc/grub2.cfg       &&  sed -i.bak 's/rhgb\ quiet//g' /etc/grub2.cfg
#配置vim
yum list installed | grep ^vim &> /dev/null || yum install vim -y
grep 'set ts=4' /etc/vimrc &> /dev/null || echo 'set ts=4' >> /etc/vimrc

#安装常用软件包
#安装编译所需工具
