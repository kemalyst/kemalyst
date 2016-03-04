src_dir = "../../src"
app_dir = "../../app"

puts "Check to see if /src exists"
if File.exists?(src_dir)
  puts "Check to see if /app exists"
  unless File.exists?(app_dir)
    puts "Renaming /src to /app"
    File.rename(src_dir, app_dir)
  end
end
