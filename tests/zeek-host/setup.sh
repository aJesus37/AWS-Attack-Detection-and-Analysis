echo -e "\n [*] Zeek Installation Steps [*]\n"
echo -e "\n [+] Updating System Packages [+]\n"
sudo dnf update -y
echo -e "\n [+] Enabling EPEL Release[+]\n"
sudo dnf install epel-release wget -y
echo -e "\n [+] Enabling Power Tools [+]\n"
sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/Rocky-PowerTools.repo
echo -e "\n [+] Adding Zeek Repository [+]\n"
sudo wget https://download.opensuse.org/repositories/security:zeek/CentOS_8/security:zeek.repo -O /etc/yum.repos.d/zeek.repo
echo -e "\n [+] Installing Zeek LTS [+]\n"
sudo dnf install zeek-lts -y

echo -e "\n [*] Filebeat Installation Steps [*]\n "
echo -e "\n [+] Download Filebeat RPM File from Elastic [+]\n"
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.14.1-x86_64.rpm
echo -e "\n [+] Installing RPM file [+]\n"
sudo rpm -vi filebeat-7.14.1-x86_64.rpm



echo -e "\n [*] Settings [*]\n"

echo -e "\n [+] Setting Hostname [+]\n"
sudo hostnamectl set-hostname 'zeek-host.ada'
sudo sed -i 's/HOSTNAME=.*$/HOSTNAME=zeek-host.ada/g' /etc/sysconfig/network
if ! grep -q HOSTNAME /etc/sysconfig/network ; then echo 'HOSTNAME=zeek-host.ada' | sudo tee -a /etc/sysconfig/network
