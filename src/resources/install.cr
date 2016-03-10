# This script will install a demo app similar to running a rails scaffold
base_dir = "../.."

# move /resources to /app
unless File.exists? "#{base_dir}/app"

  # directories to move to base directory
  dirs = ["app", "db", "config", "public"]

  dirs.each do |dir|
    unless File.exists? "#{base_dir}/#{dir}"
      File.rename "resources/#{dir}", "#{base_dir}/#{dir}"
    end
  end

end


