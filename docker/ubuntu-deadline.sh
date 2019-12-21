apt update
apt install wget libssl-dev apt-transport-https

wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

apt update
apt install dotnet-runtime-2.2

# Install Deadline
/deadline/DeadlineR*.run
/deadline/DeadlineC*.run

# Run DeadlineRCS
dotnet /opt/Thinkbox/Deadline10/bin/deadlinercs.dll