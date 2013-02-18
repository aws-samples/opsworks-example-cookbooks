node[:deploy].each do |app_name, deploy|
  execute "mysql-create-table" do
    command "/usr/bin/mysql -u#{deploy[:database][:username]} -p#{deploy[:database][:password]} #{deploy[:database][:database]} -e'CREATE TABLE #{node[:photoapp][:dbtable]}(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    url VARCHAR(255) NOT NULL,
    caption VARCHAR(255),
    PRIMARY KEY (id)
  )'"
    not_if "/usr/bin/mysql -u#{deploy[:database][:username]} -p#{deploy[:database][:password]} #{deploy[:database][:database]} -e'SHOW TABLES' | grep #{node[:photoapp][:dbtable]}"
    action :run
  end
end