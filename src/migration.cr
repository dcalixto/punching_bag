module PunchingBag
  class Migration
    def self.up(db)
      db.exec "CREATE TABLE IF NOT EXISTS punches (
        id BIGSERIAL PRIMARY KEY,
        punchable_id BIGINT NOT NULL,
        punchable_type VARCHAR NOT NULL,
        starts_at TIMESTAMP NOT NULL,
        ends_at TIMESTAMP NOT NULL,
        average_time TIMESTAMP NOT NULL,
        hits INTEGER DEFAULT 1
      )"
    end
  end
end
