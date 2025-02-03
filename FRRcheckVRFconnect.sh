#!/bin/bash
#
#TOPAZ CHECK CONNECTION IN FRR BGP DAEMON
#by disazhuravlev
VRF="vrf100"
ip="100.100.101.2"
IFACE=" 100.100.100.1"
count=3
status=connected
BGP="48343"
RD="100"
logfile=/tmp/ping.txt

echo `date +%Y.%m.%d__%H:%M:%S`'ping check in vrf started' >> ${logfile}

while [ true ]; do
    
    echo "STARTED COMMAND ip vrf exec vrf100 ping -c ${count}  -I ${IFACE} ${ip}"
    result=$(ip vrf exec vrf100 ping -c ${count}  -I 100.100.100.1 ${ip} 2<&1| grep -icE 'unknown|expired|unreachable|time out')

    
    if [ "$status" = connected -a "$result" != 0 ]; then

        status=disconnected
       
        echo `date +%Y.%m.%d__%H:%M:%S`'NO CONNECTION' >> ${logfile}
    
        echo `date +%Y.%m.%d__%H:%M:%S`'NO CONNECTION'
        echo "link to $IP in VRF $VRF NO CONNECTION. NEED RESET BGP VRF"


		if [ -f /home/root/newconf.conf ]; then
		echo "file exist"
		else
		echo "created bgp conf file"
		
		echo "router bgp "${BGP}" vrf "${VRF}" " > /home/root/newconf.conf
		echo "!" >> /home/root/newconf.conf
		echo "address-family ipv4 unicast" >> /home/root/newconf.conf
		echo "redistribute connected" >> /home/root/newconf.conf
		echo  "label vpn export auto" >> /home/root/newconf.conf
		echo  "rd vpn export 48343:"${RD}" " >> /home/root/newconf.conf
		echo  "rt vpn both 48343:"${RD}" " >> /home/root/newconf.conf
		echo  "export vpn" >> /home/root/newconf.conf
		echo  "import vpn" >> /home/root/newconf.conf
		echo  "exit-address-family" >> /home/root/newconf.conf
		echo "exit" >> /home/root/newconf.conf
		echo "!" >> /home/root/newconf.conf
		
		fi
		
		vtysh -c "conf t" -c "router bgp "${BGP}" vrf "${VRF}" "
        vtysh -c "conf t" -c "no router bgp "${BGP}" vrf "${VRF}" "
        if [ $? -eq 0 ]; then
         echo "command 'no router bgp "${BGP}" vrf "${VRF}" ' WELL DONE"
        vtysh -c "copy /home/root/newconf.conf running-config"
         if [ $? -eq 0 ]; then
         echo "command 'copy /home/root/newconf.conf running-config' WELL DONE"
         else
         echo "ERORR 'copy /home/root/newconf.conf running-config'."
        #exit 1
         fi
        else
         echo "ERROR 'no router bgp "${BGP}" vrf "${VRF}" '."
        #exit 1
        fi

        #exit 0
		
		status=connected
		



    fi
  
    if [ "$status" = disconnected -a "$result" -eq 0 ]; then
       
        status=connected
      
        echo `date +%Y.%m.%d__%H:%M:%S`'CONNECTION' >> ${logfile}
  
        echo `date +%Y.%m.%d__%H:%M:%S`'CONNECTION'
    fi
  
    sleep 5
done
