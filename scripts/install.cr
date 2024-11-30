# !/usr/bin/env crystal
require "../src/punching_bag"
require "file_utils"

# Initialize the database
DB.open(PunchingBag::Configuration.database_url) do |db|
  # Add error handling for database operations
  begin
    db.exec "CREATE TABLE IF NOT EXISTS punches (
      id INTEGER PRIMARY KEY,
      punchable_id INTEGER NOT NULL,
      punchable_type TEXT NOT NULL,
      starts_at DATETIME NOT NULL,
      ends_at DATETIME NOT NULL,
      average_time DATETIME NOT NULL,
      hits INTEGER DEFAULT 1
    )"
    # Add version tracking for schema
    db.exec "CREATE TABLE IF NOT EXISTS schema_versions (
      version INTEGER PRIMARY KEY,
      applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )"
  rescue ex : DB::Error
    puts "Database error: #{ex.message}"
    exit(1)
  end
end
# Create the bin directory and punching_bag.cr script
BIN_DIR    = "./bin"
SETUP_PATH = "./bin/punching_bag.cr"
FileUtils.mkdir_p(BIN_DIR)

unless File.exists?(setup_path)
  File.write(setup_path, <<-CODE)

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

unless PunchingBag::Configuration.database_url.starts_with?("sqlite://")
  puts "Error: Only SQLite databases are supported"
  exit(1)
end
