#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
## 对于字符串比较，要用因好全起来
## 然后对于代码运行，会直接把反映号里面的东西给替换调
## 字符串是空，和空是不一样的扼东西




get_current_pid(){


cpid=`sudo netstat -tunlp | egrep -o "[0-9]*/dhcpd"|egrep -o "([0-9])*"`

if [ -n $cpid ]
then 
	echo 现在正在运行的PID为  [ $cpid ]
else
	echo not running here
fi
	

}



getaddr(){
	echo 现在请打开树莓派，然后等待一段时间
while true
do
	ip=`cat /var/lib/dhcp/dhcpd.leases  |tail -n 14 |egrep  -o "([0-9]{,3}\.){3}([0-9]){,3}"`
	if [ -z "$ip" ]
	then
		sleep 2
		
		echo 现在没有查询到地址，请等待
	else
		break
	fi
done

	 echo RP4 分配到的IP地址为  [ $ip ]

}












empty_env(){

	sudo rm /var/lib/dhcp/*	
	sudo touch /var/lib/dhcp/dhcpd.leases
	sudo rm /var/run/dhcpd.pid
}




ifempty_eth0(){

	dev_sta=`ifconfig enp7s0|egrep -o "inet .*"`
	
	if [ -n  "$dev_sta" ]
		then 
		echo 网卡开关检测完成，这在进入下一步

		empty_env
		sudo dhcpd |egrep -o "Listening on.*/16"
	else

	echo 没有检测到活动网卡，请打开有线网卡后继续  
		
		exit
	
	fi



}







boot_dhcp(){
	ifempty_eth0

}




reboot_dhcp(){
	sudo kill -9  $1	
	ifempty_eth0
}



checkroot(){

if [ "$EUID" != "0" ]
then  
	echo 在root环境下运行这个脚本
	exit
else
	echo 权限检查通过
fi

}



try_connect(){
echo > ~/.ssh/known_hosts


echo 请输入要连接的树梅派操作系统 
echo -e "1 : >Ubuntu 20.10 \n 2 : OpenWrt "
read choi
if [ "$choi" = "1" ] 
then 
echo "Try connect to Ubuntu 20.10"
'/home/kusime/Desktop/small-tool/RUN-RP4_lib/ssh-hook-ubuntu.sh' 

elif [ "$choi" = "2" ]
then
echo "Try connect to OpenWrt"
echo [   http://$ip   ]

else
exit
fi



}




empty_router(){
sudo nmcli  device  show  |egrep  -o "IP4.ROUTE.*" |egrep -o "([0-9]{,3}\.){3}([0-9]){,3}/([0-9]){,3}">'/home/kusime/Desktop/small-tool/RUN-RP4_lib/route.net' 
sudo nmcli  device  show  |egrep  -o "IP4.ROUTE.*" |egrep -o "nh = ([0-9]{,3}\.){3}([0-9]){,3}"|egrep -o "([0-9]{,3}\.){3}([0-9]){,4}">'/home/kusime/Desktop/small-tool/RUN-RP4_lib/dest.gateway'
sudo python  '/home/kusime/Desktop/small-tool/RUN-RP4_lib/route-hook.py'
}



get_network_info(){

wlan0ipaddr=`ifconfig wlp0s20f3|egrep -o "inet .*" |awk '{print $2 }'`
gateway_waln0=`nmcli  device  show wlp0s20f3 |egrep  -o "IP4.GATEWAY.*([0-9]{,3}\.){3}([0-9]){,3}"|egrep -o "([0-9]{,3}\.){3}([0-9])"`  #192.168.0.1
gateway_eth0=`ifconfig enp7s0|egrep -o "inet .*"|awk '{print $2}'` #10.1.0.1

two_wlan0=`ifconfig wlp0s20f3|egrep -o "inet .*"|awk '{print $3 " " $4 }'`
wlan0_inden=`echo $gateway_waln0|awk -F "." '{print $1 "." $2 "." $3 "."0}'`

two_eth0=`ifconfig enp7s0|egrep -o "inet .*"|awk '{print $3 " " $4 }'`

eth0_inden=`echo $gateway_eth0|awk -F "." '{print $1 "." $2 "." $3 "."0}'`

}



add_route(){

echo [runing 1/5]    sudo route add -net $eth0_inden  $two_eth0  metric 10  enp7s0

sudo route add -net $eth0_inden  $two_eth0  metric 10  enp7s0  #eth0 basic

echo [runing 2/5]   sudo route add -net $wlan0_inden   $two_wlan0 metric 11  wlp0s20f3
sudo route add -net $wlan0_inden   $two_wlan0 metric 11  wlp0s20f3 #wlan0 basic

echo [runing 3/5]   sudo route add default gw $gateway_waln0  metric 5   wlp0s20f3
sudo route add default gw $gateway_waln0  metric 5   wlp0s20f3

echo [runing 4/5] sudo iptables -t nat --flush POSTROUTING
sudo iptables -t nat --flush POSTROUTING


}



set_network(){

get_network_info

echo get wlan0 gateway at [ $gateway_waln0 ]
echo get eth0 gateway at [ $gateway_eth0 ]

echo get wlan0 range [ $wlan0_inden $two_wlan0 ]
echo get eth0 range [ $eth0_inden  $two_eth0]

echo 格式化路由表完成
empty_router
echo 开始添加路由规则
add_route

}



checkroot


get_current_pid


if [ -z "$cpid" ]
then
	 echo 现在服务没有运行,正在配置启动
	
	boot_dhcp
        get_current_pid
	

	
	getaddr	
	set_network

echo [runing 5/5] sudo iptables -t nat -I POSTROUTING -s $ip --to-source $wlan0ipaddr
sudo iptables -t nat -I POSTROUTING -s $ip --to-source $wlan0ipaddr
echo [ runing 6/6 ] sudo sed -i s/.*rp4/"$ip      rp4"/g /etc/hosts
sudo sed -i s/.*rp4/"$ip      rp4"/g /etc/hosts
try_connect


else



	echo "Do you want to reboot the porgress ??  [ y / n] >  [!!要是不重启的话请确定树莓派现在已经和💻连接了!!]"

	read choise
	if [ $choise = "y" ]
	then 
		echo "now kill the [ $cpid ] progress then reboot the dhcp server "
		reboot_dhcp $cpid
	fi

	cpid=`sudo netstat -tunlp | egrep -o "[0-9]*/dhcpd"|egrep -o "([0-9])*"`



	set_network
	getaddr	

echo [runing 5/5] sudo iptables -t nat -I POSTROUTING -s $ip -j SNAT --to-source $wlan0ipaddr
sudo iptables -t nat -I POSTROUTING -s $ip -j SNAT --to-source $wlan0ipaddr


echo [ runing 6/6 ] sudo sed -i s/.*rp4/"$ip      rp4"/g /etc/hosts
sudo sed -i s/.*rp4/"$ip      rp4"/g /etc/hosts
try_connect

fi 






