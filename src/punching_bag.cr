require "db"
require "pg"
require "./punching_bag/version"
require "./punching_bag/configuration"
require "./punching_bag/punchable"
require "./punching_bag/tracker"
require "./punching_bag/cli"

module PunchingBag
  def self.configure(&)
    yield Configuration.config
  end

  # Helper method to verify the database setup
  def self.verify_setup
    begin
      db = DB.open(Configuration.config.database_url)

      # Check if the punches table exists
      table_exists = db.scalar("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'punches')").as(Bool)
      Log.info { "Punches table exists: #{table_exists}" }

      if !table_exists
        Log.warn { "Punches table does not exist. Creating it now..." }
        tracker = Tracker.new(db)
        tracker.setup_database

        # Verify again
        table_exists = db.scalar("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'punches')").as(Bool)
        Log.info { "After initialization, punches table exists: #{table_exists}" }
      end

      # Check if there are any records
      count = db.scalar("SELECT COUNT(*) FROM punches").as(Int64)
      Log.info { "Total punch records in database: #{count}" }

      return table_exists
    rescue ex
      Log.error(exception: ex) { "Error verifying PunchingBag setup: #{ex.message}" }
      return false
    ensure
      db.try(&.close)
    end
  end

  class Tracker
    getter db : DB::Database

    def initialize(@db : DB::Database)
      setup_database
    end

    def setup_database
      setup_table
      @db.exec "DROP INDEX IF EXISTS idx_punches_punchable"
      @db.exec "DROP INDEX IF EXISTS punchable_index"
      @db.exec "CREATE INDEX IF NOT EXISTS punchable_index ON punches (punchable_type, punchable_id)"
      @db.exec "CREATE INDEX IF NOT EXISTS idx_punches_created_at ON punches (created_at)"
    end

    def setup_table
      sql = <<-SQL
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

      @db.exec(sql)
    end

    def punch(punchable_type : String, punchable_id : Int64 | Int32, hits : Int32 = 1, timestamp : Time = Time.utc)
      # Convert Int32 to Int64 if needed
      id = punchable_id.to_i64

      @db.exec(
        "INSERT INTO punches (punchable_id, punchable_type, created_at, starts_at, ends_at, hits)
         VALUES ($1, $2, $3, $4, $5, $6)",
        args: [id, punchable_type, timestamp, timestamp, timestamp + 1.hour, hits]
      )
    end

    def total_hits(punchable_type : String, punchable_id : Int64 | Int32) : Int64
      # Convert Int32 to Int64 if needed
      id = punchable_id.to_i64

      result = @db.scalar(
        "SELECT SUM(hits) FROM punches WHERE punchable_type = $1 AND punchable_id = $2",
        punchable_type, id
      )
      case result
      when Int64
        result
      when Int32
        result.to_i64
      when Float64
        result.to_i64
      when Slice(UInt8)
        result.to_s.to_i64
      when Nil
        0_i64
      else
        raise "Unexpected result type: #{result.class}"
      end
    end

    def most_hit(since : Time, limit : Int32 = 5)
      sql = <<-SQL
        SELECT punchable_type, punchable_id, SUM(hits) as total_hits 
        FROM punches 
        WHERE created_at >= $1
        GROUP BY punchable_type, punchable_id 
        ORDER BY total_hits DESC 
        LIMIT $2
      SQL

      @db.query_all(sql, args: [since, limit], as: {punchable_type: String, punchable_id: Int64, total_hits: Int64})
    end

    def clear
      @db.exec("DELETE FROM punches")
    end
  end
end
