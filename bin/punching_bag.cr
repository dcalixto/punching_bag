#!/usr/bin/env crystal

require "../src/punching_bag"
require "punching_bag/cli"

# Execute CLI commands
if ARGV[0]? == "setup"
  PunchingBag::CLI.setup
elsif ARGV.size > 0
  PunchingBag::CLI.run(ARGV[0])
else
  puts "Usage: punching_bag <command>"
  PunchingBag::CLI.help
end
