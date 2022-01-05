# Environment variables
USER="user"
interface=`sudo /sbin/ifconfig -a | head -n 1 | cut -f 1 -d ':'`

echo -e "\n [*] Zeek Installation Steps [*]\n"
echo -e "\n [+] Updating System Packages [+]\n"
sudo dnf update -y

echo -e "\n [+] Enabling EPEL Release[+]\n"
sudo dnf install nc epel-release wget -y

echo -e "\n [+] Enabling Power Tools [+]\n"
sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/Rocky-PowerTools.repo

echo -e "\n [+] Adding Zeek Repository [+]\n"
sudo wget https://download.opensuse.org/repositories/security:zeek/CentOS_8/security:zeek.repo -O /etc/yum.repos.d/zeek.repo

echo -e "\n [+] Installing Zeek LTS [+]\n"
sudo dnf install zeek-lts -y

echo -e "\n [+] Adding user to zeek group [+]"
sudo usermod -aG zeek $USER

echo -e "\n [+] Configuring Zeek interface [+]"
sudo sed -i "s/^interface=eth0$/interface=$interface/g" /opt/zeek/etc/node.cfg

echo -e "\n [+] Configuring Zeek output format to JSON [+]"
echo -e "# The following line will make zeek output logs as JSON\n@load policy/tuning/json-logs.zeek" | sudo tee -a /opt/zeek/share/zeek/site/local.zeek

echo -e "\n [+] Configuring Zeek to start on system startup [+]"
echo -e "@reboot root /opt/zeek/bin/zeekctl deploy" | sudo tee -a /etc/crontab

echo -e "\n [*] Filebeat Installation Steps [*]\n "
echo -e "\n [+] Download Filebeat RPM File from Elastic [+]\n"
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.14.1-x86_64.rpm

echo -e "\n [+] Installing RPM file [+]\n"
sudo rpm -vi filebeat-7.14.1-x86_64.rpm

echo -e 'filebeat.inputs:\n- type: filestream\n  enabled: true\n  paths:\n    - "/opt/zeek/logs/current/*"\noutput.logstash:\n  enabled: true\n  hosts: ["172.16.0.132:5044"]\n\nlogging.to_files: true\nlogging.files:\n  path: /var/log/filebeat\n  name: filebeat\n  keepfiles: 7\n  permissions: 0644' | sudo tee /etc/filebeat/filebeat.yml

sudo systemctl enable filebeat && sudo systemctl start filebeat
sudo usermod -aG filebeat $USER
echo -e "\n [*] Settings [*]\n"

echo -e "\n [+] Setting Hostname [+]\n"
sudo hostnamectl set-hostname 'zeek-host.ada'
sudo sed -i 's/HOSTNAME=.*$/HOSTNAME=zeek-host.ada/g' /etc/sysconfig/network
if ! grep -q HOSTNAME /etc/sysconfig/network ; then echo 'HOSTNAME=zeek-host.ada' | sudo tee -a /etc/sysconfig/network ; fi

echo -e "\n [+] Setting Static IP to 172.16.0.130 [+]\n"
echo -e "DEVICE=ens32\nBOOTPROTO=none\nONBOOT=yes\nPREFIX=24\nIPADDR=172.16.0.130" | sudo tee /etc/sysconfig/network-scripts/ifcfg-$interface
echo -e "\n [*] Enabling Zeek [*]\n"
sudo /opt/zeek/bin/zeekctl deploy
sudo systemctl restart NetworkManager.service
sudo systemctl disable firewalld && sudo systemctl stop firewalld
sudo shutdown -r now