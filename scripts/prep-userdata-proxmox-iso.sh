#!/bin/sh

cat <<EOF > ./http/proxmox/linux/kali/2021.4a/preseed.cfg
# This preseed files will install a Kali Linux "Full" installation (default ISO) with no questions asked (unattended).

d-i debian-installer/locale string en_US 
d-i console-keymaps-at/keymap select us 
d-i mirror/country string enter information manually 
d-i mirror/suite string kali-rolling
d-i mirror/codename string kali-rolling 
d-i mirror/http/hostname string http.kali.org  
d-i mirror/http/directory string /kali 
d-i mirror/http/proxy string 
d-i clock-setup/utc boolean true 
d-i time/zone string US/Eastern 
# Disable volatile and security 
d-i apt-setup/services-select multiselect 

# Enable contrib and non-free
d-i apt-setup/non-free boolean true 
d-i apt-setup/contrib boolean true 

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

# Add our own security mirror 
d-i apt-setup/local0/repository string http://http.kali.org/kali kali-rolling main contrib non-free
d-i apt-setup/local0/comment string Security updates 
d-i apt-setup/local0/source boolean false 
d-i apt-setup/use_mirror boolean true
tasksel tasksel/first multiselect standard 
d-i pkgsel/upgrade select full-upgrade 
# Install a limited subset of tools from the Kali Linux repositories 
d-i pkgsel/include string openssh-server openvas metasploit-framework metasploit nano openvpn ntpupdate 
# Change default hostname 
d-i netcfg/get_hostname string unassigned-hostname 
d-i netcfg/get_domain string unassigned-domain 
d-i netcfg/hostname string ${HOSTNAME}

# Set Root Password 
d-i passwd/make-user boolean true
d-i passwd/root-password password ${PASSWORD} 
d-i passwd/root-password-again password ${PASSWORD} 

# To create a normal user account.
d-i passwd/user-fullname string ${USERNAME}
d-i passwd/username string ${USERNAME}
# Normal user's password, either in clear text
#d-i passwd/user-password password insecure
#d-i passwd/user-password-again password insecure
# or encrypted using a crypt(3) hash.
d-i passwd/user-password-crypted ${PASSWORD} [crypt(3) hash]
# Create the first user with the specified UID instead of the default.
#d-i passwd/user-uid string 1010

popularity-contest popularity-contest/participate boolean false 
d-i grub-installer/only_debian boolean true 
d-i grub-installer/with_other_os boolean false 
d-i finish-install/reboot_in_progress note


kismet kismet/install-setuid boolean false
kismet kismet/install-users string  

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
EOF
