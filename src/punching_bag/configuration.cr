module PunchingBag
  class Configuration
    property database_url : String = "postgres://postgres:postgres@localhost:5432/punching_bag_test"
    property db : DB::Database?

    @@config = Configuration.new

    def self.configure
      yield @@config
    end

    def self.config
      @@config
    end

    def self.database_url
      @@config.database_url
    end

    def self.db
      @@config.db
    end
  end
end
