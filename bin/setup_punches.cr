require "pg"
require "db"
require "micrate"

require "../src/punching_bag"

DATABASE_URL = "postgres://postgres:postgres@localhost:5432/punching_bag_test"
Micrate::DB.connection_url = DATABASE_URL

module Micrate
  module DB
    def self.record_migration(migration, is_applied)
      db.exec("INSERT INTO micrate_db_version (version_id, is_applied, tstamp) VALUES ($1, $2, $3)",
        [migration.version, is_applied, Time.utc])
    end
  end
end

Micrate::Cli.run
