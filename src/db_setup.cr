require "db"
require "pg"

module PunchingBag::Setup
  DATABASE_URL = ENV["DATABASE_URL"]? || "postgres://localhost/punching_bag_development"

  def self.run
    puts "Setting up development database..."
    setup_development_db
    puts "Creating tables and indexes..."
    setup_tables
    puts "Setup completed successfully"
  end

  private def self.setup_development_db
    DB.open("postgres://localhost/postgres") do |db|
      begin
        db.exec "CREATE DATABASE punching_bag_development"
      rescue e : DB::Error
        puts "Database might already exist: #{e.message}"
      end
    end
  end

  private def self.setup_tables
    DB.open(DATABASE_URL) do |db|
      create_punches_table(db)
      create_indexes(db)
    end
  end

  private def self.create_punches_table(db)
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
  end

  private def self.create_indexes(db)
    db.exec "CREATE INDEX IF NOT EXISTS idx_punches_punchable ON punches (punchable_type, punchable_id)"
    db.exec "CREATE INDEX IF NOT EXISTS idx_punches_created_at ON punches (created_at)"
  end
end
