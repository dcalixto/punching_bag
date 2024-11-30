#!/usr/bin/env crystal

require "punching_bag/cli"

# Check if the file exists
if !File.exists?("./bin/punching_bag.cr")
  puts "Error: Required file ./bin/punching_bag.cr is missing."
  puts "Run 'crystal run bin/punching_bag.cr -- setup' to generate the file."
  exit 1
end

# Proceed with CLI execution
if ARGV.size > 0
  PunchingBag::CLI.run(ARGV[0])
else
  puts "Usage: punching_bag <command>"
end
