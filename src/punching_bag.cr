require "db"

class PunchingBag
  @db : DB::Database

  def initialize(db : DB::Database)
    @db = db
    setup_database
  end

  private def setup_database
    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS punches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        punchable_id INTEGER NOT NULL,
        punchable_type TEXT NOT NULL,
        starts_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        average_time DATETIME NOT NULL,
        hits INTEGER DEFAULT 1
      );
    SQL

    @db.exec "CREATE INDEX IF NOT EXISTS punchable_index ON punches (punchable_type, punchable_id);"
    @db.exec "CREATE INDEX IF NOT EXISTS average_time_index ON punches (average_time);"
  end

  # def punch(punchable_type : String, punchable_id : Int32, hits : Int32 = 1, timestamp : Time = Time.utc)
  #   @db.exec("INSERT INTO punches (punchable_id, punchable_type, starts_at, ends_at, average_time, hits)
  #              VALUES (?, ?, ?, ?, ?, ?)",
  #     punchable_id, punchable_type, timestamp, timestamp + 1.hour, timestamp, hits)
  # end
  def punch(punchable_type : String, punchable_id : Int64, hits : Int32 = 1, timestamp : Time = Time.utc)
    @db.exec("INSERT INTO punches (punchable_id, punchable_type, starts_at, ends_at, average_time, hits)
               VALUES (?, ?, ?, ?, ?, ?)",
      punchable_id, punchable_type, timestamp, timestamp + 1.hour, timestamp, hits)
  end

  def average_time(punchable_type : String, punchable_id : Int64) : Time
    result = @db.query_all(
      "SELECT starts_at, hits FROM punches WHERE punchable_type = ? AND punchable_id = ?",
      punchable_type, punchable_id,
      as: {starts_at: Time, hits: Int32}
    )

    return Time.utc if result.empty?

    total_time = result.reduce(0_i64) do |sum, punch|
      sum + punch[:starts_at].to_unix * punch[:hits]
    end

    total_hits = result.reduce(0) { |sum, punch| sum + punch[:hits] }
    Time.unix(total_time // total_hits)
  end

  def total_hits(punchable_type : String, punchable_id : Int64) : Int64
    result = @db.scalar("SELECT SUM(hits) FROM punches WHERE punchable_type = ? AND punchable_id = ?", punchable_type, punchable_id)

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

  def most_hit(since : Time, limit : Int64 = 5) : Array(NamedTuple(punchable_type: String, punchable_id: Int64, total_hits: Int64))
    @db.query_all(
      "SELECT punchable_type, punchable_id, SUM(hits) as total_hits
       FROM punches
       WHERE starts_at >= ?
       GROUP BY punchable_type, punchable_id
       ORDER BY total_hits DESC
       LIMIT ?",
      since,
      limit,
      as: {punchable_type: String, punchable_id: Int64, total_hits: Int64}
    )
  end

  def clear
    @db.exec("DELETE FROM punches")
  end
end
