#!/bin/bash


######################软件包制作脚本#################################
# 本工具用于制作最终的发布软件包
# 制作软件的包的前提:
# 1.软件产品定义文件以及对应的ansable的脚本已经编写完毕，并上传到linux的某个目录
# 2.本脚本执行服务器已经docker的基础软件已经安装
# 3.本服务器能连接到公司的docker仓库
# 4.服务器上含有zip的命令
# author： zhangjian 01116211 
# data：   2020-10-15
# #######################################################################

# 将下载后的软件包进行压缩
function zipProductPackage()
{
     mkdir -p $1/dist/$2
	 rm -rf $1/dist/$2/*
	 time=$(date "+%Y-%m-%d %H:%M:%S")
	 dirdate=`date +%Y%m%d%H%M`
     sed -i -r "s;<publishTime>.*<\/publishTime>;<publishTime>${time}<\/publishTime>;g" $1/src/$2/wisedu.soft.info
     cd $1/src/$2
     zip -q -r $1/dist/$2/$3-$2_$dirdate.zip . -x "module"
	 cd $1/dist/
	 sshpass -p wisedu scp -r $1/dist/$2 root@172.16.34.88:/opt/doc/product/casp/
}

# 从仓库中下载对应的镜像，并做成tar包
function downloadDocker()
{
     # 下载docker包
     docker pull $5
     if [ $? -ne '0' ] ; then
         exit 126
     fi
	 mkdir -p $1/src/$2/install/roles/$3/files
     cd $1/src/$2/install/roles/$3/files
     rm -rf *.tar
     docker save $5 -o $3-$4.tar
}


# 程序的入口函数
function main()
{
     # 解析定义的文件，并逐行处理
     cat $1/src/$3/module | while read module_name module_version module_path; do
        if [ "x$module_name" = "x" ]; then
           echo
           echo escape empty line
           continue;
        fi
        if echo $module_name | grep '^#' >/dev/null 2>&1; then
           echo
           echo escape commented project $module_name/$module_version
           continue
        fi
        downloadDocker $1 $3 $module_name $module_version $module_path
     done 

    # 将下载后的包进行压缩
    zipProductPackage $1 $3 $2

}


dir=`dirname $0`
dir=`cd $dir; pwd`

main $dir $1 $2

