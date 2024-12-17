module PunchingBag
  class Configuration
    @@db : DB::Database? = nil

    def self.db : DB::Database
      @@db ||= DB.open(ENV["DATABASE_URL"])
    end

    def self.db=(database : DB::Database)
      @@db = database
    end
  end

  def self.configure
    yield Configuration
  end

  def self.db
    Configuration.db
  end
end
