module PunchingBag
  class Migration
    def self.up(db)
      db.exec "CREATE TABLE IF NOT EXISTS punches (
        id INTEGER PRIMARY KEY,
        punchable_id INTEGER NOT NULL,
        punchable_type TEXT NOT NULL,
        starts_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        average_time DATETIME NOT NULL,
        hits INTEGER DEFAULT 1
      )"
    end
  end
end
