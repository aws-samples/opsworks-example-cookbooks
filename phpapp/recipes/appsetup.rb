node[:deploy].each do |app_name, deploy|

  template "#{deploy[:deploy_to]}/current/db-connect.php" do
    source "db-connect.php.erb"
    mode 0660
    group deploy[:group]

    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")   
      owner "apache"
    end

    variables(
      :host =>     (deploy[:database][:host] rescue nil),
      :user =>     (deploy[:database][:username] rescue nil),
      :password => (deploy[:database][:password] rescue nil),
      :db =>       (deploy[:database][:database] rescue nil),
      :table =>    (node[:photoapp][:dbtable] rescue nil),
      :s3bucket => (node[:photobucket] rescue nil)
    )

   only_if do
     File.directory?("#{deploy[:deploy_to]}/current")
   end
  end
end
