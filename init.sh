#!/bin/bash
#此脚本用来初始化centos7,更新源，安装基础软件包等功能
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
else
    exit 3 && echo "ERROR: /etc/yum.repos.d not exist"
fi
