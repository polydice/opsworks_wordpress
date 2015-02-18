include_recipe 'deploy'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['wordpress']['keys']['auth'] = secure_password
node.set_unless['wordpress']['keys']['secure_auth'] = secure_password
node.set_unless['wordpress']['keys']['logged_in'] = secure_password
node.set_unless['wordpress']['keys']['nonce'] = secure_password
node.set_unless['wordpress']['salt']['auth'] = secure_password
node.set_unless['wordpress']['salt']['secure_auth'] = secure_password
node.set_unless['wordpress']['salt']['logged_in'] = secure_password
node.set_unless['wordpress']['salt']['nonce'] = secure_password

node[:deploy].each do |application, deploy|
  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  directory "#{deploy[:deploy_to]}/shared/wordpress" do
    owner deploy[:user]
    group deploy[:group]
    recursive true
  end

  remote_file "#{deploy[:deploy_to]}/shared/wordpress/latest.tar.gz" do
    source "https://wordpress.org/latest.tar.gz"
    not_if { ::File.exists?("#{deploy[:deploy_to]}/shared/wordpress/index.php") }
  end

  execute "tar xfz latest.tar.gz --strip-components 1" do
    cwd "#{deploy[:deploy_to]}/shared/wordpress/"
    umask 022
    only_if { ::File.exists?("#{deploy[:deploy_to]}/shared/wordpress/latest.tar.gz") }
  end

  file "#{deploy[:deploy_to]}/shared/wordpress/latest.tar.gz" do
    action :delete
    only_if { File.exists?("#{deploy[:deploy_to]}/shared/wordpress/latest.tar.gz") }
  end

  directory "#{deploy[:deploy_to]}/shared/wordpress/wp-content" do
    recursive true
    action :delete
    not_if "test -L #{deploy[:deploy_to]}/shared/wordpress/wp-content"
  end

  nginx_web_app deploy[:application] do
    docroot "#{deploy[:deploy_to]}/shared/wordpress"
    server_name deploy[:domains].first
    mounted_at deploy[:mounted_at]
    ssl_certificate_ca deploy[:ssl_certificate_ca]
    deploy deploy
    template "site.conf.erb"
    application deploy
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  link "#{deploy[:deploy_to]}/shared/wordpress/wp-content" do
    to "#{deploy[:deploy_to]}/current/wp-content"
  end

  link "#{deploy[:deploy_to]}/shared/wordpress/favicon.ico" do
    to "#{deploy[:deploy_to]}/current/favicon.ico"
  end

  template "#{deploy[:deploy_to]}/shared/wordpress/wp-config.php" do
    path "#{deploy[:deploy_to]}/shared/wordpress/wp-config.php"
    source "wp-config.php.erb"
    owner deploy[:user]
    group deploy[:group]
    mode 0644
    variables(:database => deploy[:database])
  end
end


