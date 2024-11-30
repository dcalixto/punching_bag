require "spec"
require "db"
require "sqlite3"
require "../src/punching_bag"

ENV["DATABASE_URL"] = "sqlite3://./test.db"

Spec.before_each do
  PunchingBag.configure do |config|
    config.database_url = ENV["DATABASE_URL"]
  end

  # Create test database tables
  DB.open(ENV["DATABASE_URL"]) do |db|
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS punches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        punchable_id INTEGER NOT NULL,
        punchable_type TEXT NOT NULL,
        starts_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        average_time DATETIME NOT NULL,
        hits INTEGER DEFAULT 1
      );
    SQL

    db.exec "CREATE INDEX IF NOT EXISTS punchable_index ON punches (punchable_type, punchable_id);"
    db.exec "CREATE INDEX IF NOT EXISTS average_time_index ON punches (average_time);"
  end
end
Spec.after_each do
  File.delete("./test.db") if File.exists?("./test.db")
end
