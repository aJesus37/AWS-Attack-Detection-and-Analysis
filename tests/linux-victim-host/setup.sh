# Environment variables
USER="user"
interface=`sudo /sbin/ifconfig -a | head -n 1 | cut -f 1 -d ':'`
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "\n [+] Updating System Packages [+]\n"
sudo dnf update -y

echo -e "\n [+] Enabling EPEL Release[+]\n"
sudo dnf install nc epel-release wget -y

echo -e "\n [+] Enabling Power Tools [+]\n"
sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/Rocky-PowerTools.repo

echo -e "\n [*] Auditbeat Installation Steps [*]\n "
echo -e "\n [+] Download Auditbeat RPM file from Elastic [+]\n"
curl -L -O curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.15.1-x86_64.rpm

echo -e "\n [+] Installing RPM file [+]\n"
sudo rpm -vi auditbeat-7.15.1-x86_64.rpm

sudo systemctl enable auditbeat && sudo systemctl start auditbeat
sudo usermod -aG auditbeat $USER

sudo cp -f $SCRIPT_DIR/auditbeat.yml /etc/auditbeat/auditbeat.yml



echo -e "\n [+] Setting Static IP to 172.16.0.134 [+]\n"
echo -e "DEVICE=ens32\nBOOTPROTO=none\nONBOOT=yes\nPREFIX=24\nIPADDR=172.16.0.134" | sudo tee /etc/sysconfig/network-scripts/ifcfg-$interface
echo -e "\n [*] Finishing config [*]\n"
sudo systemctl restart NetworkManager.service
sudo systemctl disable firewalld && sudo systemctl stop firewalld
sudo shutdown -r now