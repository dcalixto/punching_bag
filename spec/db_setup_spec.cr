require "./spec_helper"
require "../src/db_setup"

describe PunchingBag do
  before_each do
    File.delete("./punching_bag.db") if File.exists?("./punching_bag.db")
  end

  after_each do
    File.delete("./punching_bag.db") if File.exists?("./punching_bag.db")
  end

  describe ".configure" do
    it "allows setting custom database url" do
      PunchingBag.configure do |config|
        config.database_url = "sqlite3://:memory:"
      end
      PunchingBag::Configuration.database_url.should eq("sqlite3://:memory:")
    end
  end

  describe "database setup" do
    it "creates punches table with correct schema" do
      DB.open(PunchingBag::Configuration.database_url) do |db|
        result = db.query_one("SELECT sql FROM sqlite_master WHERE type='table' AND name='punches'", as: String)
        result.should contain("CREATE TABLE punches")
        result.should contain("id INTEGER PRIMARY KEY AUTOINCREMENT")
        result.should contain("punchable_id INTEGER NOT NULL")
        result.should contain("punchable_type TEXT NOT NULL")
        result.should contain("starts_at DATETIME NOT NULL")
        result.should contain("ends_at DATETIME NOT NULL")
        result.should contain("average_time DATETIME NOT NULL")
        result.should contain("hits INTEGER DEFAULT 1")
      end
    end

    it "creates required indexes" do
      DB.open(PunchingBag::Configuration.database_url) do |db|
        indexes = db.query_all("SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='punches'", as: String)
        indexes.should contain("punchable_index")
        indexes.should contain("average_time_index")
      end
    end

    it "maintains idempotency when running setup multiple times" do
      3.times do
        DB.open(PunchingBag::Configuration.database_url) do |db|
          index_count = db.scalar("SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND tbl_name='punches'").as(Int64)
          index_count.should eq(2)
        end
      end
    end
  end
end
