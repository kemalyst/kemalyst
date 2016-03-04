base_dir = "../.."

# move /src to /app
if File.exists? "#{base_dir}/src"
  unless File.exists? "#{base_dir}/app"
    File.rename "#{base_dir}/src", "#{base_dir}/app"
  end

  # create structure
  dirs = ["app/controllers", "app/models", "app/views", "config", "db",
        "logs", "public/javascripts", "public/stylesheets"]

  dirs.each do |dir|
    unless File.exists? "#{base_dir}/#{dir}"
      Dir.mkdir_p "#{base_dir}/#{dir}"
    end
  end
end


