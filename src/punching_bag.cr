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
end