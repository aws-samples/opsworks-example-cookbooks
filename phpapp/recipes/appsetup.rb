log node[:phpapp][:dbtable].inspect

script "install_composer" do
  interpreter "bash"
  user "root"
  cwd "#{node[:deploy][:myphpapp][:deploy_to]}/current"
  code <<-EOH
  curl -s https://getcomposer.org/installer | php
  php composer.phar install
  EOH
end


template "#{node[:deploy][:myphpapp][:deploy_to]}/current/db-connect.php" do
  source "db-connect.php.erb"
  mode 0660
  node[:deploy][:group]

if platform?("ubuntu")
  owner "www-data"
elsif platform?("amazon")   
  owner "apache"
end


  variables(
      :host =>     (node[:deploy][:myphpapp][:database][:host] rescue nil),
      :user =>     (node[:deploy][:myphpapp][:database][:username] rescue nil),
      :password => (node[:deploy][:myphpapp][:database][:password] rescue nil),
      :db =>       (node[:deploy][:myphpapp][:database][:database] rescue nil),
      :table =>    (node[:phpapp][:dbtable] rescue nil)
  )

 only_if do
   File.directory?("#{node[:deploy][:myphpapp][:deploy_to]}/current")
 end
end
