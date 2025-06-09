module PunchingBag
  module Punchable
    # This method should be called in the model's class
    macro included
      def track_view
        return unless id = @id # Early return if id is nil

        begin
          # Get the class name for the punchable_type
          punchable_type = self.class.name

          # Create a tracker instance
          tracker = PunchingBag::Tracker.new(self.class.db)

          # Record the hit
          tracker.punch(punchable_type, id, 1, Time.utc)

          Log.info { "View tracked for #{punchable_type} ##{id}" }
          return true
        rescue ex
          Log.error(exception: ex) { "Failed to track view for #{self.class.name} ##{id}: #{ex.message}" }
          return false
        end
      end

      def view_count
        return 0_i64 unless id = @id

        begin
          # Get the class name for the punchable_type
          punchable_type = self.class.name

          # Create a tracker instance
          tracker = PunchingBag::Tracker.new(self.class.db)

          # Get the total hits
          tracker.total_hits(punchable_type, id)
        rescue ex
          Log.error(exception: ex) { "Error getting view count for #{self.class.name} ##{id}: #{ex.message}" }
          return 0_i64
        end
      end

      # Class methods
      def self.trending(since = Time.utc - 1.week, limit = 10)
        tracker = PunchingBag::Tracker.new(self.db)
        tracker.most_hit(since, limit: limit)
      end
    end
  end
end
