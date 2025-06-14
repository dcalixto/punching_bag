module PunchingBag
  class Tracker
    getter db : DB::Database

    # Singleton pattern to avoid repeated initializations
    @@instance : Tracker? = nil

    def self.instance(db : DB::Database) : Tracker
      @@instance ||= new(db)
    end

    def initialize(@db : DB::Database)
      Log.debug { "Inicializando PunchingBag::Tracker" }
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
      ends_at TIMESTAMPTZ DEFAULT (CURRENT_TIMESTAMP + INTERVAL '1 hour')
    )
  SQL

      @db.exec(sql)
    end

    def punch(punchable_type : String, punchable_id : Int64 | Int32, hits : Int32 = 1, timestamp : Time = Time.utc)
      id = punchable_id.to_i64
      sql = <<-SQL
    INSERT INTO punches (
      punchable_type,  -- Ordem correta: tipo primeiro
      punchable_id,    -- ID segundo
      hits,
      created_at,
      starts_at,
      ends_at
    ) VALUES ($1, $2, $3, $4, $5, $6)
  SQL

      args = [
        punchable_type,     # 1: String
        id,                 # 2: Int64
        hits,               # 3: Int32
        timestamp,          # 4: Time
        timestamp,          # 5: Time (starts_at)
        timestamp + 1.hour, # 6: Time (ends_at)
      ]

      Log.debug { "Executando: #{sql} com args: #{args}" }

      begin
        @db.exec(sql, args: args)
        Log.info { "Punch registrado para #{punchable_type} ##{id}" }
        true
      rescue ex : DB::Error
        Log.error(exception: ex) { "FALHA no INSERT: #{ex.message}" }
        false
      end
    end

    # Batch punch multiple items at once for better performance
    def batch_punch(items : Array(NamedTuple(type: String, id: Int64 | Int32, hits: Int32)))
      return true if items.empty?

      timestamp = Time.utc

      sql = <<-SQL
        INSERT INTO punches (punchable_type, punchable_id, hits, created_at, starts_at, ends_at)
        VALUES 
      SQL

      values = [] of String
      args = [] of DB::Any

      items.each_with_index do |item, index|
        base = index * 6
        values << "($#{base + 1}, $#{base + 2}, $#{base + 3}, $#{base + 4}, $#{base + 5}, $#{base + 6})"

        args << item[:type]
        args << item[:id].to_i64
        args << item[:hits]
        args << timestamp
        args << timestamp
        args << timestamp + 1.hour
      end

      sql += values.join(", ")

      begin
        @db.exec(sql, args: args)
        Log.info { "Batch punch registrado para #{items.size} items" }
        true
      rescue ex : DB::Error
        Log.error(exception: ex) { "FALHA no batch INSERT: #{ex.message}" }
        false
      end
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
      when String
        result.to_i64
      when Nil
        0_i64
      else
        Log.warn { "Unexpected result type in total_hits: #{result.class}" }
        0_i64
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

    # Get trending items with the highest growth rate in hits
    def trending(days : Int32 = 7, limit : Int32 = 10)
      sql = <<-SQL
        WITH recent_hits AS (
          SELECT 
            punchable_type, 
            punchable_id, 
            SUM(hits) as recent_total 
          FROM punches 
          WHERE created_at >= $1
          GROUP BY punchable_type, punchable_id
        ),
        older_hits AS (
          SELECT 
            punchable_type, 
            punchable_id, 
            SUM(hits) as older_total 
          FROM punches 
          WHERE created_at >= $2 AND created_at < $1
          GROUP BY punchable_type, punchable_id
        )
        SELECT 
          r.punchable_type, 
          r.punchable_id, 
          r.recent_total as recent_hits,
          COALESCE(o.older_total, 0) as older_hits,
          r.recent_total - COALESCE(o.older_total, 0) as growth
        FROM recent_hits r
        LEFT JOIN older_hits o ON r.punchable_type = o.punchable_type AND r.punchable_id = o.punchable_id
        ORDER BY growth DESC
        LIMIT $3
      SQL

      now = Time.utc
      recent_start = now - days.days
      older_start = recent_start - days.days

      @db.query_all(
        sql,
        args: [recent_start, older_start, limit],
        as: {
          punchable_type: String,
          punchable_id:   Int64,
          recent_hits:    Int64,
          older_hits:     Int64,
          growth:         Int64,
        }
      )
    end

    # Get hourly statistics for a specific item
    def hourly_stats(punchable_type : String, punchable_id : Int64 | Int32, days : Int32 = 7)
      id = punchable_id.to_i64

      sql = <<-SQL
        SELECT 
          date_trunc('hour', created_at) as hour,
          SUM(hits) as total_hits
        FROM punches
        WHERE punchable_type = $1 
          AND punchable_id = $2
          AND created_at >= $3
        GROUP BY hour
        ORDER BY hour ASC
      SQL

      since = Time.utc - days.days

      @db.query_all(
        sql,
        args: [punchable_type, id, since],
        as: {hour: Time, total_hits: Int64}
      )
    end

    def clear
      @db.exec("DELETE FROM punches")
    end

    # Clean up old data to keep the database size manageable
    def cleanup(older_than : Time)
      sql = "DELETE FROM punches WHERE created_at < $1"
      result = @db.exec(sql, args: [older_than])
      Log.info { "Cleaned up #{result.rows_affected} old punch records" }
      result.rows_affected
    end

    def average_time(punchable_type : String, punchable_id : Int64 | Int32) : Time
      id = punchable_id.to_i64

      sql = <<-SQL
        SELECT AVG(created_at) as avg_time
        FROM punches
        WHERE punchable_type = $1 AND punchable_id = $2
      SQL

      result = @db.query_one?(sql, args: [punchable_type, id], as: {avg_time: Time?})

      if result && result[:avg_time]
        result[:avg_time]
      else
        # Return current time if no punches exist
        Time.utc
      end
    end

    # Add this method to the Tracker class
    def self.with_connection(db_url : String? = nil, &block)
      db_url ||= PunchingBag::Configuration.config.database_url

      # If a connection URL is provided, open a new connection
      db = DB.open(db_url)
      tracker = new(db)

      begin
        yield tracker
      ensure
        db.close
      end
    end

    # Add a static method for convenience
    def self.track(punchable_type : String, punchable_id : Int64, hits = 1, time = Time.utc)
      begin
        db = DB.open(PunchingBag::Configuration.config.database_url)
        tracker = PunchingBag::Tracker.new(db)
        result = tracker.punch(punchable_type, punchable_id, hits, time)
        Log.info { "Punch registrado para #{punchable_type} ##{punchable_id}" }
        result
      rescue ex
        Log.error(exception: ex) { "Failed to track view for #{punchable_type} ##{punchable_id}: #{ex.message}" }
        false
      ensure
        db.try(&.close)
      end
    end
  end
end