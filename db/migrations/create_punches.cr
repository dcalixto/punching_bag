class CreatePunches < DB::Migration
  def up
    execute <<-SQL
      CREATE TABLE punches (
        id BIGSERIAL PRIMARY KEY,
        punchable_id BIGINT NOT NULL,
        punchable_type VARCHAR NOT NULL,
        starts_at TIMESTAMP NOT NULL,
        ends_at TIMESTAMP NOT NULL,
        average_time TIMESTAMP NOT NULL,
        hits INTEGER DEFAULT 1
      );

      CREATE INDEX punchable_index 
      ON punches (punchable_type, punchable_id);

      CREATE INDEX average_time_index
      ON punches (average_time);
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS punches;
      DROP INDEX IF EXISTS punchable_index;
      DROP INDEX IF EXISTS average_time_index;
    SQL
  end
end
