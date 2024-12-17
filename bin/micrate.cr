require "micrate"
require "db"

DATABASE_URL = ENV["DATABASE_URL"]? || "postgres://daniel:password@localhost/kemal_db"
Micrate::DB.connection_url = DATABASE_URL
Micrate::Cli.run
