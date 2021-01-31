#
# Cookbook:: win_mariadb
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

# Get the MySQL user details from the DataBag
mysqluser = Chef::EncryptedDataBagItem.load('topsecret', 'mysql')

directory "Create folder C:/tmp" do
  path "C:/tmp"
  recursive true
end

# Downloading isn't the problem. Installing silently is
#remote_file 'Download .Net Framework 4.8' do
#  source 'https://go.microsoft.com/fwlink/?linkid=2088631'
#  path 'C:\tmp\ndp48-x86-x64-allos-enu.exe'
#  mode '0755'
#  notifies :run, 'execute[Install .Net Framework]' , :immediately
#end
# Have to execute this manually. Silent execution doesn't work!!!
#execute 'Install .Net Framework' do
#  command 'C:\tmp\ndp48-x86-x64-allos-enu.exe /norestart'
#  action :nothing
#  notifies :run, 'reboot[Post .Net Framework Install]' , :immediately
#end
#reboot 'Post .Net Framework Install' do
#  reason 'dotnetframework requires a reboot to complete'
#  action :nothing
#end

# Have to manually download and execute because the MSI gets corrupted
# So download on the workstation and copy it into the nodes
#remote_file 'Download MariaDB MSI' do
#  source 'https://downloads.mariadb.org/interstitial/mariadb-10.5.8/winx64-packages/mariadb-10.5.8-winx64.msi/from/https%3A//mariadb.mirror.liquidtelecom.com/'
#  path 'C:\tmp\mariadb-10.5.8-winx64.msi'
#  mode '0755'
#end
cookbook_file 'Copy MariaDB MSI' do
  source 'mariadb-10.5.8-winx64.msi'
  path 'C:\tmp\mariadb-10.5.8-winx64.msi'
end

# Ensure .NetFramework > 1.1 is installed
windows_package 'Install MariaDB' do
  package_name 'mariadb'
  action :install
  installer_type :msi
  source 'C:\tmp\mariadb-10.5.8-winx64.msi'
  options "PORT=3306 ALLOWREMOTEROOTACCESS=true PASSWORD=#{mysqluser['password']} SERVICENAME=MySQL"
end

windows_path 'Add the MySQL command to the path' do
  path 'C:\Program Files\MariaDB 10.5\bin'
  action :add
  only_if { ::File.exist?('C:\Program Files\MariaDB 10.5\bin') }
end
