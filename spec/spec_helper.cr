require "spec"
require "../src/punching_bag"

module TestHelper
  # DB_URL = "postgres://postgres@localhost/punching_bag_test"
  DB_URL = "postgres://daniel:password@localhost/punching_bag_test"
  @@database : DB::Database? = nil

  def self.database
    @@database ||= DB.open(DB_URL)
  end

  def self.setup_database
    @@database = DB.open(DB_URL)
    PunchingBag.db = database
    database.exec "DROP TABLE IF EXISTS punches CASCADE"
  end

  def self.cleanup_database
    @@database.try &.close
    @@database = nil
  end
end

Spec.before_suite { TestHelper.setup_database }
Spec.after_suite { TestHelper.cleanup_database }
