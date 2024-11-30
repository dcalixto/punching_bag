require "./punching_bag"

class PunchingBag::CLI
  def self.setup
    DB.open(PunchingBag::Configuration.database_url) do |db|
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
    true
  end

  def self.run(command : String)
    case command
    when "setup"
      setup
    else
      false
    end
  end
end
