#
# Cookbook:: win_mariadb
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

dir = ['C:\tmp', 'C:\inetpub\wwwroot\Bin']

dir.each do |d|
  directory "Create folder #{d}" do
    path "#{d}"
    recursive true
  end
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
  options 'PORT=3306 ALLOWREMOTEROOTACCESS=true PASSWORD=dbrootpass SERVICENAME=MySQL'
end

windows_path 'Add the MySQL command to the path' do
  path 'C:\Program Files\MariaDB 10.5\bin'
  action :add
  only_if { ::File.exist?('C:\Program Files\MariaDB 10.5\bin') }
end

#remote_file 'Download MySQL connector' do
#  #source 'https://dev.mysql.com/get/archives/mysql-connector-net-1.0/mysql-connector-net-1.0.10.exe'
#  source 'https://dev.mysql.com/downloads/file/?id=501708'
#  path 'C:\tmp\mysql-connector-net-8.0.23.msi'
#  mode '0755'
#  notifies :run, 'execute[Install the MySQL connector]', :immediately
#end
cookbook_file 'Copy MySQL Connector' do
  source 'mysql-connector-net-8.0.23.msi'
  path 'C:\tmp\mysql-connector-net-8.0.23.msi'
end

remote_directory 'Copy .Net Project' do
  source 'simple_db_dot_net'
  path 'C:/inetpub/wwwroot/simple'
  recursive true
  notifies :run, 'execute[Execute the SQL file]', :immediately
end

execute 'Install the MySQL connector' do
  command 'C:\tmp\mysql-connector-net-8.0.23.msi /q'
  creates 'C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.23\Assemblies\v4.5.2\MySql.Data.dll'
end

powershell_script 'Copy DLL' do
  code 'copy "C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.23\Assemblies\v4.5.2\MySql.Data.dll" C:/inetpub/wwwroot/Bin/'
  creates 'C:/inetpub/wwwroot/Bin/MySql.Data.dll'
  only_if { ::File.exist?('C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.23\Assemblies\v4.5.2\MySql.Data.dll') }
end

execute 'Execute the SQL file' do
  command 'mysql -h 127.0.0.1 -u root -pdbrootpass -e "source C:/inetpub/wwwroot/simple/SQL/MySQL.sql"'
  cwd     'C:\Program Files\MariaDB 10.5\bin'
  not_if  'C:\Program Files\MariaDB 10.5\bin\mysql -h 127.0.0.1 -u root -pdbrootpass ajaxsamples -e "SELECT 1 from customers";'
end
