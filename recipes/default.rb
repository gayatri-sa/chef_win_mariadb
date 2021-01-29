#
# Cookbook:: win_mariadb
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

windows_package 'Install MariaDB' do
  package_name 'mariadb'
  action :install
  source 'https://downloads.mariadb.org/interstitial/mariadb-10.5.8/winx64-packages/mariadb-10.5.8-winx64.msi/from/https%3A//mirrors.bkns.vn/mariadb/'
end
