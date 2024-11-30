require "db"

module PunchingBag
  class Migrator
    def self.migrate
      DB.connect(ENV["DATABASE_URL"]) do |db|
        CreatePunches.new.up
      end
    end
  end
end
