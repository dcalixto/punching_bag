#!/usr/bin/env crystal
require "../src/punching_bag"
require "file_utils"

# Create the bin directory and punching_bag.cr script
BIN_DIR    = "./bin"
SETUP_PATH = "./bin/punching_bag.cr"
FileUtils.mkdir_p(BIN_DIR)

unless File.exists?(SETUP_PATH)
  File.write(SETUP_PATH, <<-CODE)
  require "punching_bag/cli"

  if ARGV.size > 0
    PunchingBag::CLI.run(ARGV[0])
  else
    puts "Usage: punching_bag <command>"
  end
  CODE
  puts "Setup complete. File created at #{SETUP_PATH}"
else
  puts "Setup already completed. File exists at #{SETUP_PATH}"
end
