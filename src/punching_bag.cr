require "db"
require "pg"
require "./punching_bag/version"
require "./punching_bag/configuration"
require "./punching_bag/tracker"
require "./punching_bag/cli"

module PunchingBag
  def self.configure
    yield Configuration.config
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

    def average_time(punchable_type : String, punchable_id : Int64)
      sql = <<-SQL
        SELECT COALESCE(
          MIN(created_at) AT TIME ZONE 'UTC',
          CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
        ) as avg_time
        FROM punches 
        WHERE punchable_type = $1 
          AND punchable_id = $2
      SQL

      @db.query_one(sql, args: [punchable_type, punchable_id]) { |rs| rs.read(Time) }
    end

    def punch(punchable_type : String, punchable_id : Int64, hits : Int32 = 1, timestamp : Time = Time.utc)
      @db.exec(
        "INSERT INTO punches (punchable_id, punchable_type, created_at, starts_at, ends_at, hits)
         VALUES ($1, $2, $3, $4, $5, $6)",
        args: [punchable_id, punchable_type, timestamp, timestamp, timestamp + 1.hour, hits]
      )
    end

    def total_hits(punchable_type : String, punchable_id : Int64) : Int64
      result = @db.scalar(
        "SELECT SUM(hits) FROM punches WHERE punchable_type = $1 AND punchable_id = $2",
        punchable_type, punchable_id
      )
      case result
      when Int64
        result
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
