module TestHelper
  @@db : DB::Database?

  def self.database
    @@db ||= DB.open(PunchingBag::Configuration.database_url)
  end
end
