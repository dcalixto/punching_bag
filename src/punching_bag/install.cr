require "punching_bag/tracker"

module PunchingBag::Install
  def self.run(db_url)
    DB.open(db_url) do |db|
      PunchingBag::Tracker.new(db).setup_table # Use Tracker#setup_table
    end
  end
end
