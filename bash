#!/bin/bash


# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
   echo -e  "\e[93m This script must be run as root \e[0m"
   exit 1
fi

echo -e "\e[1;36;40m Server Hardening initiated \e[0m"
cd /usr/local/src
rm -f csf* &> /dev/null
echo -e "\e[1;36;40m Installing CSF.....\e[0m"
wget https://download.configserver.com/csf.tgz > /dev/null 2>&1
tar -xzf csf.tgz        > /dev/null 2>&1
cd csf
[ -d /etc/csf  ] && cp -rpf /etc/csf /etc/csf-`date +%d-%m-%y-%T`
sh install.sh  > /dev/null 2>&1

echo -e "\e[1;36;40m Modifying parameters in CSF configuration \e[0m"
sleep 3
sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERMEM = "512"/PT_USERMEM = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERPROC = "10"/PT_USERPROC = "0"/g' /etc/csf/csf.conf
sed -i 's/RESTRICT_SYSLOG = "0"/ RESTRICT_SYSLOG = "3"/g' /etc/csf/csf.conf
sed -i 's/SMTP_BLOCK = "0"/SMTP_BLOCK = "1"/g' /etc/csf/csf.conf
sed -i 's/SYSLOG_CHECK = "0"/SYSLOG_CHECK = "3600"/g' /etc/csf/csf.conf
sed -i 's/LF_SCRIPT_ALERT = "0"/LF_SCRIPT_ALERT = "1"/'  /etc/csf/csf.conf
echo -e "\e[1;36;40m restarting csf \e[0m"
csf -r   > /dev/null 2>&1

# INSTALL MALDET

echo -e " \e[1;36;40m Installing maldet scanner \e[0m"
cd /usr/local/src/
rm -f maldetect* &>/dev/null
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz > /dev/null 2>&1
tar -xzf maldetect-current.tar.gz
cd maldetect-*
sh ./install.sh > /dev/null 2>&1

echo -e "\e[1;36;40m Enabling auto quarantine in maldet configuration \e[0m"
sed -i 's/quarantine_hits="0"/quarantine_hits="1"/g' /usr/local/maldetect/conf.maldet

#INSTALL CLAMAV CPANEL

######  This command tells the system that we want ClamAV to be listed as installed by the local RPM system:

echo -e "\e[1;36;40m INSTALLING CLAMSCAN \e[0m"
/scripts/update_local_rpm_versions --edit target_settings.clamav installed  > /dev/null 2>&1

######  This command is the one responsible for installing the ClamAV RPM on your server:

/scripts/check_cpanel_rpms --fix --targets=clamav   > /dev/null 2>&1
