# install dkms
    apt-get install dkms 用于管理linux编译安装内核模块
# 底层安装virtualbox包
    dpkg -i virtualbox-5.1_5.1.0-108711-Ubuntu-trusty_amd64.deb 

# 使用过程

'''
编辑source.list添加如下内容deb http://download.virtualbox.org/virtualbox/debian trusty contrib
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
apt-get update
apt-get install virtualbox-5.1
wget http://download.virtualbox.org/virtualbox/5.1.0/Oracle_VM_VirtualBox_Extension_Pack-5.1.0-108711.vbox-extpack 下载扩展
vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-5.1.0-108711.vbox-extpack 安装扩展 
vboxmanage list ostypes 查看支持的虚拟机类型
vboxmanage list vms 查看已存在的虚拟机
vboxmanage createvm --name "ubuntu1204-base" --ostype "Ubuntu_64" --basefolder "/home/cxl/virtualbox/vm/" --register 创建虚拟机
vboxmanage unregistervm ubuntu1204-base --delete 删除虚拟机
lsmod |grep vbox 检查是否安装vbox
vboxmanage createhd --filename /home/cxl/virtualbox/vm/ubuntu1204-base/ubuntu1204-base --size 8000 创建虚拟硬盘
ll /home/cxl/virtualbox/vm/ubuntu1204-base 发现只有2m的vdi 
vboxmanage storagectl "ubuntu1204-base" --add scsi  --name "scsi controller" --bootable on  创建scsi接口
vboxmanage storageattach "ubuntu1204-base" --storagectl "scsi controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1204-base/ubuntu1204-base.vdi" 虚拟机关联硬盘
vboxmanage storageattach "ubuntu1204-base" --storagectl "scsi controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-12.04.1-server-amd64.iso" 虚拟机关联光驱，加入iso安装文件
vboxmanage modifyvm "ubuntu1204-base" --memory 512 --vram 8 --nic1 bridged --bridgeadapter1 eth0 --vrde on --vrdeport 5000
vboxmanage storagectl "ubuntu1204-base" --name "scsi controller" --remove 清除虚拟机挂载的硬盘光驱
vboxmanage storagectl "ubuntu1204-base" --add ide  --name "ide controller" --bootable on  创建ide接口
vboxmanage storageattach "ubuntu1204-base" --storagectl "ide controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1204-base/ubuntu1204-base.vdi" 虚拟机关联硬盘
vboxmanage storageattach "ubuntu1204-base" --storagectl "ide controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-12.04.1-server-amd64.iso" 虚拟机关联光驱，加入iso安装文件
vboxmanage startvm "ubuntu1204-base" --type headless
vboxmanage storagectl "ubuntu1204-base" --add ide  --name "IDE Controller" --bootable on  创建ide接口
vboxmanage storageattach "ubuntu1204-base" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1204-base/ubuntu1204-base.vdi" 虚拟机关联硬盘
vboxmanage storageattach "ubuntu1204-base" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-12.04.1-server-amd64.iso" 虚拟机关联光驱，加入iso安装文件
vboxmanage modifyvm "ubuntu1204-base" --vrdeport 5001
vboxmanage clonevm "ubuntu1204-base" --name "buildserver" --register --basefolder "/home/cxl/virtualbox/vm/" 
vboxmanage startvm "buildserver" --type headless
vboxmanage controlvm buildserver poweroff
vboxmanage modifyvm buildserver --vrde off
vboxmanage createvm --name "ubuntu1604-base" --ostype "Ubuntu_64" --basefolder "/home/cxl/virtualbox/vm/" --register  //创建1604虚拟机
vboxmanage createhd --filename /home/cxl/virtualbox/vm/ubuntu1604-base/ubuntu1604-base --size 8000
vboxmanage storagectl "ubuntu1604-base" --add scsi  --name "scsi controller" --bootable on  创建scsi接口
vboxmanage storageattach "ubuntu1604-base" --storagectl "scsi controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1604-base/ubuntu1604-base.vdi" 虚拟机关联硬盘
vboxmanage storageattach "ubuntu1604-base" --storagectl "scsi controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-16.04-server-amd64.iso" 虚拟机关联光驱，加入iso安装文件
vboxmanage modifyvm "ubuntu1604-base" --memory 512 --vram 8 --nic1 bridged --bridgeadapter1 eth0 --vrde on --vrdeport 5000
vboxmanage startvm "ubuntu1604-base" --type headless
vboxmanage storagectl "ubuntu1604-base" --name "scsi controller" --remove
vboxmanage storagectl "ubuntu1604-base" --add ide  --name "ide controller" --bootable on
vboxmanage storageattach "ubuntu1604-base" --storagectl "ide controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1604-base/ubuntu1604-base.vdi" 虚拟机关联硬盘
vboxmanage storageattach "ubuntu1604-base" --storagectl "ide controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-16.04-server-amd64.iso" 虚拟机关联光驱，加入iso安装文件
vboxmanage modifyvm "20-buildserver" --name "21-buildserver" --vrde off修改虚拟机名称


vboxmanage modifyvm 232ubuntu12g30 --nic1 none
vboxmanage modifyvm 232ubuntu12g30 --nic1 bridged --bridgeadapter1 eth0
'''

root


配置ip地址
1、vim /etc/network/interfaces  
2、auto eth0  
   iface eth0 inet static  
    address 10.0.0.234  
    netmask 255.255.255.0  
    gateway 10.0.0.254  
    dns-nameservers 8.8.8.8 202.106.0.20 
3、 /etc/init.d/networking restart

samba
1、testparm -v -s|grep usershare
2、vi /etc/samba/smb.conf
3、smbclient //localhost/cxl 123456

ssh
1、ssh root@10.0.0.232
2、vi /etc/ssh/sshd_config
找到：PermitRootLogin prohibit-password禁用 //1604配置
添加：PermitRootLogin yes //1604配置
3、service ssh restart

查看系统内核
uname -a
查看ubuntu版本
cat /etc/issue

修改root密码
sudo su root
passwd

源码安装git（1204）
1、apt-get install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
2、make prefix=/usr/local all
3、sudo make prefix=/usr/local install
4、git --version （git version 2.9.0.GIT）
5、apt-get install subversion-tools（git svn使用）
6、cpan
7、install Term::ReadKey

mysql导入导出
使用包括列名的完整的INSERT语句 -c
使用包括几个VALUES列表的多行INSERT语法。这样使转储文件更小，重载文件时可以加速插入。-e
不写重新创建每个转储表的CREATE TABLE语句。 -t
--compact导出更少的输出信息(用于调试)。去掉注释和头尾等结构。可以使用选项：--skip-add-drop-table  --skip-add-locks --skip-comments --skip-disable-keys

mysqldump -u root -p123456 -c -e -t talk talk_sip_member talk_enterprise_group --compact --where="eid=8" > talk1.sql

mysqldump -u root -p123456 -c -e  talk talk_enterprise --compact --where="id=8" > talk_enterprise.sql
mysqldump -u root -p123456 -c -e  talk talk_sip_member talk_enterprise_group talk_call_record talk_callcenter_node talk_company_addr talk_customer talk_customer_event talk_enterprise_group talk_enterprise_profile talk_fileinfo talk_group_member talk_group_order talk_group_profile talk_integral_detail talk_log talk_maintenance_sync talk_member_customer talk_member_event talk_member_outnumber talk_member_profile talk_pub_account talk_signin talk_sync talk_yimishop talk_voice_file --compact --where="eid=8" > talk_eid.sql
mysqldump -u root -p123456 -c -e  talk talk_user --compact --where="enterprise_id=8" > talk_user.sql
mysqldump -u root -p123456 -c -e  talk talk_callcenter_group talk_callcenter_members talk_callcenter_node_profile --compact --where="cnid in (select id from talk_callcenter_node where eid=8)" > talk_callcenter.sql

select * from information_schema.columns where 
