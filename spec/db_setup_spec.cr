require "./spec_helper"
require "../src/db_setup"

describe "database setup" do
  it "creates punches table with correct schema" do
    bag = PunchingBag::Tracker.new(PunchingBag.db)
    bag.setup_database

    result = PunchingBag.db.query_all(<<-SQL, as: {column_name: String, data_type: String})
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'punches'
      ORDER BY ordinal_position
    SQL

    result.should contain({column_name: "id", data_type: "bigint"})
    result.should contain({column_name: "punchable_type", data_type: "character varying"})
    result.should contain({column_name: "hits", data_type: "integer"})
    result.should contain({column_name: "created_at", data_type: "timestamp with time zone"})
  end

  it "creates required indexes" do
    DB.open(PunchingBag::Configuration.database_url) do |db|
      indexes = db.query_all(<<-SQL, as: String)
        SELECT indexname 
        FROM pg_indexes 
        WHERE tablename = 'punches' 
        AND indexname != 'punches_pkey';
      SQL

      indexes.should contain("punchable_index")
      indexes.should contain("idx_punches_created_at")
    end
  end

  it "maintains idempotency when running setup multiple times" do
    3.times do
      DB.open(PunchingBag::Configuration.database_url) do |db|
        index_count = db.scalar(<<-SQL).as(Int64)
          SELECT COUNT(*) 
          FROM pg_indexes 
          WHERE tablename = 'punches' 
          AND indexname != 'punches_pkey';
        SQL
        index_count.should eq(2)
      end
    end
  end
end
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
        config.database_url = "postgres://localhost/punching_bag_test"
      end
      PunchingBag::Configuration.database_url.should eq("postgres://localhost/punching_bag_test")
    end
  end
end
