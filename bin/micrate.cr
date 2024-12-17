require "db"
require "pg"
require "micrate"

DATABASE_URL = ENV["DATABASE_URL"]? || "postgres://daniel:password@localhost/kemal_db"
Micrate::DB.connection_url = DATABASE_URL

# PostgreSQL implementation
module Micrate
  module DB
    def self.record_migration(migration, is_applied)
      current_time = Time.unix(Time.utc.to_unix)
      db.exec("INSERT INTO micrate_db_version (version_id, is_applied, tstamp) VALUES ($1, $2, $3)",
        [migration.version, is_applied, current_time])
    end
  end
end

Micrate::Cli.run
