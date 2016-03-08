base_dir = "../.."

# move /resources to /app
unless File.exists? "#{base_dir}/app"

  # create structure
  dirs = ["app", "db", "config", "public"]

  dirs.each do |dir|
    unless File.exists? "#{base_dir}/#{dir}"
      File.rename "resources/#{dir}", "#{base_dir}/#{dir}"
    end
  end

end


