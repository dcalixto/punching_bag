require "spec"
require "webmock"
require "../src/punching_bag"
require "db"
require "pg"
require "micrate"

DB_URL = "postgres://postgres:postgres@localhost:5432/punching_bag_test"

Spec.before_each do
  WebMock.reset

  # Clean database first
  DB.open(DB_URL) do |db|
    db.exec "DROP TABLE IF EXISTS punches"
    db.exec "DROP TABLE IF EXISTS micrate_db_version"
  end

  # Run migrations
  Micrate::DB.connection_url = DB_URL
  Micrate::Cli.run_up
end

PunchingBag.configure do |config|
  config.database_url = DB_URL
  config.db = DB.open(DB_URL)
end

# No need to run migrations down since we're dropping tables in before_each
