# Environment variables
USER="user"
interface=`sudo /sbin/ifconfig -a | head -n 1 | cut -f 1 -d ':'`
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "\n [*] Updating System Packages [*]\n"
sudo dnf update -y

echo -e "\n [*] Logstash Installation Steps [*]\n"

echo -e "\n [*] Installing Logstash [*]\n"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo -e "[logstash-7.x]\nname=Elastic repository for 7.x packages\nbaseurl=https://artifacts.elastic.co/packages/7.x/yum\ngpgcheck=1\ngpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch\nenabled=1\nautorefresh=1\ntype=rpm-md" | sudo tee -a /etc/yum.repos.d/logstash.repo
sudo dnf install nc logstash -y
echo -e "\n [*] Configuring logstash [*]\n"
sudo cp -f $SCRIPT_DIR/logstash.conf /etc/logstash/conf.d/default-beat.conf

sudo systemctl enable logstash && sudo systemctl start logstash
sudo usermod -aG logstash $USER
echo -e "\n [*] Settings [*]\n"

echo -e "\n [+] Setting Hostname [+]\n"
sudo hostnamectl set-hostname 'logstash-host.ada'
sudo sed -i 's/HOSTNAME=.*$/HOSTNAME=logstash-host.ada/g' /etc/sysconfig/network 2> /dev/null
if ! [[ $(grep -q HOSTNAME /etc/sysconfig/network 2> /dev/null) ]]; then
    echo 'HOSTNAME=logstash-host.ada' | sudo tee -a /etc/sysconfig/network
fi

echo -e "\n [+] Setting Static IP to 172.16.0.132 [+]\n"
echo -e "DEVICE=ens32\nBOOTPROTO=none\nONBOOT=yes\nPREFIX=24\nIPADDR=172.16.0.132" | sudo tee /etc/sysconfig/network-scripts/ifcfg-$interface
sudo systemctl restart NetworkManager.service
sudo systemctl disable firewalld && sudo systemctl stop firewalld
sudo shutdown -r now