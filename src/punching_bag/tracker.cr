def setup_table
  drop_table
  create_table
  create_indexes
end

private def drop_table
  @db.exec("DROP TABLE IF EXISTS punches CASCADE")
end

private def create_table
  @db.exec <<-SQL
      CREATE TABLE punches (
        id BIGSERIAL PRIMARY KEY,
        punchable_type VARCHAR(255),
        punchable_id BIGINT,
        hits INTEGER DEFAULT 1,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        starts_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        ends_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
      )
    SQL
end

private def create_indexes
  @db.exec("CREATE INDEX IF NOT EXISTS idx_punches_punchable ON punches(punchable_type, punchable_id)")
end
