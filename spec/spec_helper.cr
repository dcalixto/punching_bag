require "spec"
require "webmock"
require "../src/punching_bag"

ENV["DATABASE_URL"] = "postgres://localhost/punching_bag_test" # Or a different test database

module TestHelper
  # DB_URL = "postgres://daniel:password@localhost/punching_bag_test"
  @@database : DB::Database? = nil

  def self.database
    @@database ||= DB.open(ENV["DATABASE_URL"]? || "postgres://postgres:postgres@localhost:5432/punching_bag_test")
  end

  def self.setup_database
    @@database = DB.open(ENV["DATABASE_URL"]? || "postgres://postgres:postgres@localhost:5432/punching_bag_test")
    PunchingBag.db = database
    database.exec "DROP TABLE IF EXISTS punches CASCADE" # Assuming this is your table
  end

  def self.cleanup_database
    @@database.try &.close
    @@database = nil
  end
end

Spec.before_suite { TestHelper.setup_database }
Spec.after_suite { TestHelper.cleanup_database }
# Mocking setup
WebMock.allow_net_connect = false
