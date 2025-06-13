require "log"

module PunchingBag
  module Punchable
    # This method should be called in the model's class
    macro included
      def track_view
        return unless id = @id # Early return if id is nil

        begin
          # Get the class name for the punchable_type
          punchable_type = self.class.name

          # Create a tracker instance with the database connection
          tracker = PunchingBag::Tracker.new(DB.open(PunchingBag::Configuration.config.database_url))

          # Record the hit
          tracker.punch(punchable_type, id, 1, Time.utc)

          Log.debug { "View tracked for #{punchable_type} ##{id}" }
          return true
        rescue ex
          Log.error(exception: ex) { "Failed to track view for #{self.class.name} ##{id}: #{ex.message}" }
          return false
        ensure
          tracker.try(&.db.close)
        end
      end

      def view_count
        return 0_i64 unless id = @id

        begin
          # Get the class name for the punchable_type
          punchable_type = self.class.name

          # Create a tracker instance with the database connection
          db = if DB.responds_to?(:get_connection)
                 # Use connection pool if available
                 DB.get_connection(PunchingBag::Configuration.config.database_url)
               else
                 # Create a new connection if needed
                 DB.open(PunchingBag::Configuration.config.database_url)
               end

          tracker = PunchingBag::Tracker.new(db)

          # Get the total hits
          tracker.total_hits(punchable_type, id)
        rescue ex
          Log.error(exception: ex) { "Error getting view count for #{self.class.name} ##{id}: #{ex.message}" }
          return 0_i64
        ensure
          tracker.try(&.db.close) unless DB.responds_to?(:get_connection)
        end
      end

      # Class methods
      def self.trending(since = Time.utc - 1.week, limit = 10)
        tracker = PunchingBag::Tracker.new(DB.open(PunchingBag::Configuration.config.database_url))

        begin
          results = tracker.most_hit(since, limit: limit)

          # Filter results for this specific model type
          model_name = self.name
          results.select { |result| result[:punchable_type] == model_name }
        rescue ex
          Log.error(exception: ex) { "Error getting trending #{self.name}: #{ex.message}" }
          [] of {punchable_type: String, punchable_id: Int64, total_hits: Int64}
        ensure
          tracker.try(&.db.close)
        end
      end
    end
  end
end
