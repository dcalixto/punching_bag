module PunchingBag
  class Configuration
    property database_url : String = ENV["DATABASE_URL"]? || "postgres://localhost/punching_bag_development"
    property db : DB::Database?

    @@config = nil

    def self.configure
      yield @@config
    end

    def self.config
      @@config ||= Configuration.new
    end

    def self.database_url
      @@config.database_url
    end

    def self.db
      @@config.db
    end
  end
end