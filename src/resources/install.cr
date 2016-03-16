# This script will install a demo app similar to running a rails scaffold
base_dir = "../.."

# move /resources to /app
unless File.exists? "#{base_dir}/app"

  # resources to move to base directory
  resources = ["app", "db", "config", "public", "Dockerfile", "docker-compose.yml"]

  resources.each do |resource|
    unless File.exists? "#{base_dir}/#{resource}"
      File.rename "resources/#{resource}", "#{base_dir}/#{resource}"
    end
  end

end


