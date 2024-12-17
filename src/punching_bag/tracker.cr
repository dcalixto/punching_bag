module PunchingBag
  class Tracker
    def initialize(@db : DB::Database)
    end

    def hit(punchable_type : String, punchable_id : Int32)
      @db.exec(
        "INSERT INTO hits (punchable_type, punchable_id, hits, created_at, updated_at)
         VALUES ($1, $2, 1, NOW(), NOW())
         ON CONFLICT (punchable_type, punchable_id)
         DO UPDATE SET hits = hits.hits + 1, updated_at = NOW()",
        punchable_type, punchable_id
      )
    end

    def setup_table
      drop_table
      create_table
      create_indexes
    end

    private def drop_table
      @db.exec("DROP TABLE IF EXISTS hits CASCADE")
    end

    private def create_table
      @db.exec <<-SQL
          CREATE TABLE hits (
            id BIGSERIAL PRIMARY KEY,
            punchable_type VARCHAR(255),
            punchable_id BIGINT,
            hits INTEGER DEFAULT 1,
            created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
          )
        SQL
    end

    private def create_indexes
      @db.exec("CREATE UNIQUE INDEX IF NOT EXISTS idx_hits_punchable ON hits(punchable_type, punchable_id)")
    end
  end
end
