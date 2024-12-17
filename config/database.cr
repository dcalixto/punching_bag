require "db"
require "pg"

DB_URL = ENV["DATABASE_URL"]? || "postgres://daniel:password@localhost/kemal_db"
DB.open(DB_URL)
