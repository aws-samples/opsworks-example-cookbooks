execute "mysql-create-table" do
  command "/usr/bin/mysql -u#{node[:deploy][:myphotoapp][:database][:username]} -p#{node[:deploy][:myphotoapp][:database][:password]} #{node[:deploy][:myphotoapp][:database][:database]} -e'CREATE TABLE #{node[:photoapp][:dbtable]}(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  url VARCHAR(255) NOT NULL,
  caption VARCHAR(255),
  PRIMARY KEY (id)
)'"
  not_if "/usr/bin/mysql -u#{node[:deploy][:myphotoapp][:database][:username]} -p#{node[:deploy][:myphotoapp][:database][:password]} #{node[:deploy][:myphotoapp][:database][:database]} -e'SHOW TABLES' | grep #{node[:photoapp][:dbtable]}"
  action :run
end
