require "db"

class PunchingBag
  @@db : DB::Database? = nil

  def self.db
    @@db || raise "Database connection not set. Call PunchingBag.db = your_database_connection first"
  end

  def self.db=(connection : DB::Database)
    @@db = connection
  end
end

# Database connection
DB.open(PunchingBag::Configuration.database_url) do |db|
  db.exec <<-SQL
    CREATE TABLE IF NOT EXISTS punches (
      id BIGSERIAL PRIMARY KEY,
      punchable_id BIGINT NOT NULL,
      punchable_type VARCHAR NOT NULL,
      starts_at TIMESTAMP NOT NULL,
      ends_at TIMESTAMP NOT NULL,
      average_time TIMESTAMP NOT NULL,
      hits INTEGER DEFAULT 1
    );
  SQL

  db.exec <<-SQL
    CREATE INDEX IF NOT EXISTS punchable_index
    ON punches (punchable_type, punchable_id);
  SQL

  db.exec <<-SQL
    CREATE INDEX IF NOT EXISTS average_time_index
    ON punches (average_time);
  SQL
end
# Database connection
# DB.open(PunchingBag::Configuration.database_url) do |db|
#   db.exec <<-SQL
#     CREATE TABLE IF NOT EXISTS punches (
#       id BIGSERIAL PRIMARY KEY,
#       punchable_id BIGINT NOT NULL,
#       punchable_type VARCHAR NOT NULL,
#       starts_at TIMESTAMP NOT NULL,
#       ends_at TIMESTAMP NOT NULL,
#       average_time TIMESTAMP NOT NULL,
#       hits BIGINT DEFAULT 1
#     );
#   SQL

#   db.exec <<-SQL
#     CREATE INDEX IF NOT EXISTS punchable_index
#     ON punches (punchable_type, punchable_id);
#   SQL

#   db.exec <<-SQL
#     CREATE INDEX IF NOT EXISTS average_time_index
#     ON punches (average_time);
#   SQL
# end
