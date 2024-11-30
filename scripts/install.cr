require "../src/punching_bag"
require "file_utils"

# Initialize the database
DB.open(PunchingBag::Configuration.database_url) do |db|
  db.exec "CREATE TABLE IF NOT EXISTS punches (
    id INTEGER PRIMARY KEY,
    punchable_id INTEGER NOT NULL,
    punchable_type TEXT NOT NULL,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    average_time DATETIME NOT NULL,
    hits INTEGER DEFAULT 1
  )"
end

# Create the bin directory and punching_bag.cr script
FileUtils.mkdir_p("./bin")
setup_path = "./bin/punching_bag.cr"

unless File.exists?(setup_path)
  File.write(setup_path, <<-CODE)
#!/usr/bin/env crystal

require "punching_bag/cli"

if ARGV.size > 0
  PunchingBag::CLI.run(ARGV[0])
else
  puts "Usage: punching_bag <command>"
end
  CODE
  puts "Setup complete. File created at #{setup_path}"
else
  puts "Setup already completed. File exists at #{setup_path}"
end
