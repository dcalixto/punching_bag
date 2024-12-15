module PunchingBag
  class Configuration
    class_property database_url : String = "postgres://postgres:postgres@localhost:5432/punching_bag_test"

    @@db : DB::Database?

    def self.db
      @@db ||= DB.open(database_url)
    end
  end

  def self.configure
    yield Configuration
  end

  def self.db
    Configuration.db
  end
end
