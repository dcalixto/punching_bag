class CreatePunches < DB::Migration
  def up
    execute <<-SQL
      CREATE TABLE punches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        punchable_id INTEGER NOT NULL,
        punchable_type TEXT NOT NULL,
        starts_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        average_time DATETIME NOT NULL,
        hits INTEGER NOT NULL DEFAULT 1
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
