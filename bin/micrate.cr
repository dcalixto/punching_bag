require "micrate"
require "db"

DATABASE_URL = ENV["DATABASE_URL"]?
Micrate::DB.connection_url = DATABASE_URL
Micrate::Cli.run
