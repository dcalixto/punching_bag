module PunchingBag
  class Migration
    def self.up(db)
      db.exec <<-SQL
        CREATE TABLE IF NOT EXISTS punches (
          id BIGSERIAL PRIMARY KEY,
          punchable_type VARCHAR(255),
          punchable_id BIGINT,
          hits INTEGER DEFAULT 1,
          created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          starts_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          ends_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        )
      SQL

      db.exec "CREATE INDEX IF NOT EXISTS idx_punches_punchable ON punches (punchable_type, punchable_id)"
      db.exec "CREATE INDEX IF NOT EXISTS idx_punches_created_at ON punches (created_at)"
    end
  end
end
