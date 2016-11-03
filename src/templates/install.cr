# This script will install a demo app similar to running a rails scaffold
base_dir = "../.."

# move /resources to project
unless File.exists? "#{base_dir}/src/app.cr"

  # move the conflicting files to old
  conflicts = ["spec/spec_helper.cr"]
  conflicts.each do |conflict|
    if File.exists? "#{base_dir}/#{conflict}"
      File.rename "#{base_dir}/#{conflict}", "#{base_dir}/#{conflict}_old"
    end
  end

  # templates to move to base directory
  templates = ["src/controllers", "src/models","src/views", "src/app.cr",
               "spec/controllers", "spec/models", "spec/spec_helper.cr",
               "db", "config", "public", "Dockerfile", "docker-compose.yml"]

  templates.each do |template|
    unless File.exists? "#{base_dir}/#{template}"
      File.rename "templates/#{template}", "#{base_dir}/#{template}"
    end
  end

end


