######
#  ONLY armhf
#  DOES NOT WORK RELIABLY YET
#based on the usermods in the armbian repo



echo  "Adding gpg-key for Kali repository"
curl --max-time 60 -4 -fsSL "https://archive.kali.org/archive-key.asc" | gpg --dearmor -o /usr/share/keyrings/kali.gpg
echo "Adding sources.list for Kali."
echo "deb [arch=armhf signed-by=/usr/share/keyrings/kali.gpg] http://http.kali.org/kali kali-rolling main non-free contrib" | tee /etc/apt/sources.list.d/kali.list
echo "Updating package lists with Kali Linux repos"
apt-get update
#echo "Installing Top 10 Kali Linux tools"
#apt-get install kali-tools-top10

echo "Adding Kali Linux profile package list show "

mkdir -p "${SDCARD}"/etc/armbian/
cat <<- 'armbian-kali-motd' > /etc/armbian/kali.sh
		#!/bin/bash
		#
		# Copyright (c) Authors: https://www.armbian.com/authors
		#
		echo -e "\n\e[0;92mAdditional security oriented packages you can install:\x1B[0m (sudo apt install kali-tools-package_name)\n"
		apt list 2>/dev/null | grep kali-tools | grep -v installed | cut -d"/" -f1 | pr -2 -t
		echo ""
	armbian-kali-motd
chmod +x /etc/armbian/kali.sh
echo ". /etc/armbian/kali.sh" >> /etc/skel/.bashrc
echo ". /etc/armbian/kali.sh" >> /etc/skel/.zshrc
echo ". /etc/armbian/kali.sh" >> /root/.bashrc
