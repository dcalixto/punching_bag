require "../spec_helper"

describe "PunchingBag Installation" do
  it "should create punches table with correct schema" do
    bag = PunchingBag::Tracker.new(TestHelper.database)
    bag.setup_database

    results = TestHelper.database.query_all(<<-SQL, as: {String, String, String})
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'punches'
      ORDER BY ordinal_position
    SQL

    expected_schema = [
      {"id", "bigint", "NO"},
      {"punchable_type", "character varying", "YES"},
      {"punchable_id", "bigint", "YES"},
      {"hits", "integer", "YES"},
      {"created_at", "timestamp with time zone", "YES"},
      {"starts_at", "timestamp with time zone", "YES"},
      {"ends_at", "timestamp with time zone", "YES"},
    ]
    results.should eq(expected_schema)
  end
end
