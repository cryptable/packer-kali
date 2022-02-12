#!/bin/sh

cat <<EOF > ./http/vmware/linux/kali/2021.4a/preseed.cfg
# This preseed files will install a Kali Linux "Full" installation (default ISO) with no questions asked (unattended).

d-i debian-installer/locale string en_US 
d-i console-keymaps-at/keymap select be
d-i mirror/country string enter information manually 
d-i mirror/suite string kali-rolling
d-i mirror/codename string kali-rolling 
d-i mirror/http/hostname string http.kali.org 
d-i mirror/http/directory string /kali 
d-i mirror/http/proxy string 

d-i clock-setup/utc boolean true 
d-i time/zone string Europe/Brussels

# Disable volatile and security 
d-i apt-setup/services-select multiselect 

# Enable contrib and non-free
d-i apt-setup/non-free boolean true 
d-i apt-setup/contrib boolean true 

# Disable source repositories too
d-i apt-setup/enable-source-repositories boolean false

# Partitioning
d-i partman-auto/method string regular 
d-i partman-lvm/device_remove_lvm boolean true 
d-i partman-md/device_remove_md boolean true 
d-i partman-lvm/confirm boolean true 
d-i partman-auto/choose_recipe select atomic 
d-i partman/confirm_write_new_label boolean true 
d-i partman/choose_partition select finish 
d-i partman/confirm boolean true 
d-i partman/confirm_nooverwrite boolean true

# Disable CDROM entries after install
d-i apt-setup/disable-cdrom-entries boolean true

# Upgrade installed packages
d-i pkgsel/upgrade select none

tasksel tasksel/first multiselect meta-default, desktop-xfce

# Change default hostname 
d-i netcfg/get_hostname string ${HOSTNAME}
d-i netcfg/get_domain string
d-i netcfg/hostname string ${HOSTNAME}
d-i netcfg/choose_interface select auto
#d-i netcfg/choose_interface select eth0
d-i netcfg/dhcp_timeout string 60

d-i hw-detect/load_firmware boolean false

# Set Root Password 
d-i passwd/make-user boolean false
d-i passwd/root-password password toor
d-i passwd/root-password-again password toor

d-i passwd/user-fullname string ${USERNAME} 
d-i passwd/username string ${USERNAME}
d-i passwd/user-password password ${PASSWORD}
d-i passwd/user-password-again password ${PASSWORD}
d-i user-setup/allow-password-weak boolean true

popularity-contest popularity-contest/participate boolean false

d-i apt-setup/use_mirror boolean true
d-i grub-installer/only_debian boolean true 
d-i grub-installer/with_other_os boolean false 
d-i grub-installer/bootdev string /dev/sda 
d-i finish-install/reboot_in_progress note

#kismet kismet/install-setuid boolean false
#kismet kismet/install-users string  

sslh sslh/inetd_or_standalone select standalone

mysql-server-5.5 mysql-server/root_password_again ${PASSWORD}  
mysql-server-5.5 mysql-server/root_password ${PASSWORD}    
mysql-server-5.5 mysql-server/error_setting_password error  
mysql-server-5.5 mysql-server-5.5/postrm_remove_databases boolean false
mysql-server-5.5 mysql-server-5.5/start_on_boot boolean true
mysql-server-5.5 mysql-server-5.5/nis_warning note  
mysql-server-5.5 mysql-server-5.5/really_downgrade boolean false
mysql-server-5.5 mysql-server/password_mismatch error   
mysql-server-5.5 mysql-server/no_upgrade_when_using_ndb error

d-i pkgsel/include string openssh-server
d-i pkgsel/include string open-vm-tools
d-i preseed/late_command string \
  in-target systemctl enable ssh; \
  in-target sed -i 's/^#*\(send dhcp-client-identifier\).*$/\1 = hardware;/' /etc/dhcp/dhclient.conf ; \
  in-target sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers ; \
  echo 'Defaults:${USERNAME} !requiretty' > /target/etc/sudoers.d/${USERNAME} ; \
  echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /target/etc/sudoers.d/${USERNAME} ; \
  in-target chmod 440 /etc/sudoers.d/${USERNAME}
EOF
