base_dir = "../.."
src_dir = "#{base_dir}/src"
app_dir = "#{base_dir}/app"

# move /src to /app
if File.exists? src_dir
  unless File.exists? app_dir
    File.rename src_dir, app_dir
  end
else
  unless File.exists? app_dir
    Dir.mkdir app_dir
  end
end

# create structure
dirs = ["app/controllers", "app/models", "app/views", "config", "db",
        "logs", "public/javascripts", "public/stylesheets"]

dirs.each do |dir|
  unless File.exists? dir
    Dir.mkdir_p dir
  end
end

