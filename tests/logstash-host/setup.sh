echo -e "\n [*] Updating System Packages [*]\n"
sudo dnf update -y

echo -e "\n [*] Logstash Installation Steps [*]\n"

echo -e "\n [*] Installing Logstash [*]\n"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo -e "[logstash-7.x]\nname=Elastic repository for 7.x packages\nbaseurl=https://artifacts.elastic.co/packages/7.x/yum\ngpgcheck=1\ngpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch\nenabled=1\nautorefresh=1\ntype=rpm-md" | sudo tee -a /etc/yum.repos.d/logstash.repo
sudo dnf install logstash -y
echo -e "\n [*] Settings [*]\n"

echo -e "\n [+] Setting Hostname [+]\n"
sudo hostnamectl set-hostname 'logstash-host.ada'
sudo sed -i 's/HOSTNAME=.*$/HOSTNAME=logstash-host.ada/g' /etc/sysconfig/network 2> /dev/null
if ! [[ $(grep -q HOSTNAME /etc/sysconfig/network 2> /dev/null) ]]; then
    echo 'HOSTNAME=logstash-host.ada' | sudo tee -a /etc/sysconfig/network
fi