require "./spec_helper"

describe "DB Setup" do
  describe "database connection" do
    it "creates punches table with correct schema" do
      db = TestHelper.database
      bag = PunchingBag::Tracker.new(db)
      bag.setup_database

      result = db.query_all(<<-SQL, as: {column_name: String, data_type: String})
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
  end
end

describe "table schema" do
  it "has the expected columns" do
    DB.open(PunchingBag::Configuration.database_url) do |db|
      result = db.query_all(<<-SQL, as: {column_name: String, data_type: String})
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
  end
end

describe PunchingBag::Configuration do
  before_each do
    PunchingBag.configure do |config|
      config.database_url = "postgres://postgres:postgres@localhost:5432/punching_bag_test"
    end
  end

  it "connects to database" do
    DB.open(PunchingBag::Configuration.database_url) do |db|
      # Your test code here
    end
  end
end
