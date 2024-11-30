#!/usr/bin/env crystal

require "../src/punching_bag"

class CLI
  def self.run
    case ARGV[0]?
    when "setup"
      PunchingBag::CLI.setup
      exit 0
    else
      puts "Usage: punching_bag [setup]"
      exit 1
    end
  end
end

CLI.run
