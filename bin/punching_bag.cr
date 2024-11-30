#!/usr/bin/env crystal

require "../src/cli"

if ARGV.size > 0
  PunchingBag::CLI.run(ARGV[0])
end
