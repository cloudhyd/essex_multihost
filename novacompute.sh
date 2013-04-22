#!/bin/bash
#########################################################################################################
#                                                                                                       #
#  The Scripts were created to simlipyfy the Openstack Installation for General Users.                  #
#                                                                                                       #
#  Created Date : 26 March 2013                                                                         #
#                                                                                                       #
#  Created By : Shivaram Y & Shyam Y                                                                    #
#                                                                                                       #
#  Support Gorups : Cloudconverge & Cloudhyd                                                            #
#                                                                                                       #
#  Email: yshivaram@yahoo.com & yedurushyam@hotmail.com                                                 #
#                                                                                                       #
#########################################################################################################

LOG_FILE=cloudhyd_opinstallation.log
#################################################################
function check_root() {
clear
. /etc/InstInfo.env
echo " Starting Installation of Openstack module '$0' `date` ">> $LOG_FILE
echo "Checking User  " >>$LOG_FILE
echo "Checking User  " 
echo "  "
sleep 1
if [ "$(id -u)" != "0" ]; then
echo "User is not root " >>$LOG_FILE
echo "You should be 'root' or use sudo to execute the commands "  >>$LOG_FILE
echo "You should be 'root' or use sudo to execute the commands " 1>&2
echo " "
else
echo "User is Root Process started" >>$LOG_FILE
echo "User is Root Process started" 
echo " "
fi
 }
##############################
function Install_nova() {
if [ -d /etc/nova ]; then
echo "Nova Image  Service already Installed " >>$LOG_FILE
echo "Nova Image  Service already Installed "
exit 1
else
echo "Installing Nova Service" >>$LOG_FILE
echo "Downloading Packages for Nova Service" >>$LOG_FILE
echo "Installing Nova Service"
sleep 2
echo ""
echo ""
apt-get install -y nova-compute nova-compute-kvm nova-network
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of Nova Service is completed" >>$LOG_FILE
echo " Installation of Nova Service is completed"
else
echo ""
echo ""
echo " Error Installing Nova Service Check Internet connection" >>$LOG_FILE
echo " Error Installing Nova ServiceCheck Internet connection"
exit 1
fi
fi

}
function getinfo() {
MASTER=$(/sbin/ifconfig eth0| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')
###############################
read -p "Enter Openstack Controller IP Address  : " CSYSTEM_IP
echo "Enter root password of Openstack Controller System : " 
scp -r root@$CSYSTEM_IP:/etc/nova/api-paste.ini /etc/nova/api-paste.ini
if [ "$?" -eq 0 ]; then
echo "Copied file /etc/nova/api-paste.ini " >>$LOG_FILE
else
echo "Error in Copying file /etc/nova/api-paste.ini " >>$LOG_FILE
echo "Error in Copying file /etc/nova/api-paste.ini "
echo "exiting " >>$LOG_FILE
exit 1
fi
sed -e "
   s,127.0.0.1,$CSYSTEM_IP,g;
   " -i /etc/nova/api-paste.ini
if [ "$?" -eq 0 ]; then
echo "Modified /etc/nova/api-paste.ini " >>$LOG_FILE
else
echo "Error in Modifying /etc/nova/api-paste.ini " >>$LOG_FILE
echo "Error in Modifying /etc/nova/api-paste.ini "
echo "exiting " >>$LOG_FILE
exit 1
fi

echo "Re-Enter root password of Openstack Controller System : " 
scp -r root@$CSYSTEM_IP:/etc/nova/nova.conf /etc/nova/nova.conf
if [ "$?" -ne 0 ]; then
echo " Error Creating /etc/nova/nova.conf " >>$LOG_FILE
echo " Error Creating /etc/nova/nova.conf "
exit 1
else 
echo "  Created file /etc/nova/nova.conf " >>$LOG_FILE
echo "  Created file /etc/nova/nova.conf " 
fi
echo "--my_ip=$MASTER " >>/etc/nova/nova.conf 
}

function config_nova() {
. /etc/InstInfo.env
echo "Configuring Nova Service" >>$LOG_FILE
echo "Configuring Nova Service"
echo " "
echo " Making Backup of files " >>$LOG_FILE
echo " Making Backup of files "
cp /etc/nova/api-paste.ini /etc/nova/api-paste.ini.bkp 
cp /etc/nova/nova.conf /etc/nova/nova.conf.bkp 
echo " "
echo " Modifying the Nova Configaration files " >>$LOG_FILE
echo " Modifying the Nova Configaration files "
##########
getinfo
#########
echo ""
echo "Completed Configuration of Nova Service" >>$LOG_FILE
echo "Completed Configuration of Nova Service"
echo ""
}

}
function restart_nova() {

echo ""
echo "Restarting the nova service" >>$LOG_FILE
echo "Restarting the nova service"
for a in libvirt-bin nova-network nova-compute ; do service "$a" stop; done
for a in libvirt-bin nova-network nova-compute ; do service "$a" start; done
if [ "$?" -ne 0 ]; then
echo " error Restarting  nova Service " >>$LOG_FILE
echo " error Restarting  nova Service "
exit 1
else 
sleep 4
echo " Nova Service Restarted " >>$LOG_FILE
echo " Nova Service Restarted "
fi
}

