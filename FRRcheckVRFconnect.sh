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


        vtysh -c "conf t" -c "no router bgp "${BGP}" vrf "${VRF}" "
        if [ $? -eq 0 ]; then
         echo "command 'no router bgp "${BGP}" vrf "${VRF}" ' WELL DONE"
        vtysh -c "copy /home/root/test.conf running-config"
         if [ $? -eq 0 ]; then
         echo "command 'copy /home/root/test.conf running-config' WELL DONE"
         else
         echo "ERORR 'copy /home/root/test.conf running-config'."
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
