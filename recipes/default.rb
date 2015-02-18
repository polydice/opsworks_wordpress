include_recipe 'hhvm'
include_recipe 'nginx'

service "hhvm" do
  action :start
end

directory "#{node[:nginx][:dir]}/global" do
  owner 'root'
  group 'root'
  recursive true
end

%w{restrictions wordpress}.each do |conf|
  template "#{node[:nginx][:dir]}/global/#{conf}.conf" do
    path "#{node[:nginx][:dir]}/global/#{conf}.conf"
    source "#{conf}.conf"
    owner 'root'
    group 'root'
    mode 0644
  end
end

cron "wordpress" do
  minute "10"
  command "/usr/bin/curl localhost/wp-cron.php"
end
