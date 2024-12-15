require "./spec_helper"

describe PunchingBag do
  it "tracks and retrieves hits correctly" do
    bag = PunchingBag::Tracker.new(TestHelper.database)
    bag.clear

    # Insert data for the test
    bag.punch("Post", 1_i64, 2)
    bag.punch("Post", 1_i64, 1)

    # Debugging: Print all records
    all_hits = bag.most_hit(Time.utc - 1.year)
    pp all_hits

    # Test expectation
    bag.total_hits("Post", 1_i64).should eq(3_i64)
  end

  it "calculates average time correctly for multiple punches" do
    bag = PunchingBag::Tracker.new(TestHelper.database)
    bag.clear

    now = Time.utc
    bag.punch("Article", 1_i64, 2, now - 2.days)
    bag.punch("Article", 1_i64, 3, now - 1.day)

    avg_time = bag.average_time("Article", 1_i64)
    (avg_time - (now - 2.days)).total_seconds.abs.should be < 1
  end

  it "returns UTC time when no punches exist" do
    bag = PunchingBag::Tracker.new(TestHelper.database)
    bag.clear

    now = Time.utc
    avg_time = bag.average_time("Post", 1)

    avg_time.should be_close(now, 1.second)
  end

  it "calculates average time for single punch" do
    bag = PunchingBag::Tracker.new(TestHelper.database)
    bag.clear

    specific_time = Time.utc
    bag.punch("Post", 1_i64, 1, specific_time)

    result = bag.average_time("Post", 1_i64)
    result.should be_close(specific_time, 1.second)
  end
end
describe "Database Setup" do
  it "creates punches table with correct schema" do
    db = TestHelper.database
    sql = <<-SQL
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'punches'
      ORDER BY ordinal_position
    SQL

    results = db.query_all(sql) do |rs|
      {
        name:     rs.read(String),
        type:     rs.read(String),
        nullable: rs.read(String),
      }
    end

    timestamp_columns = ["created_at", "starts_at", "ends_at"]
    timestamp_columns.each do |col|
      column = results.find { |r| r[:name] == col }
      column.should_not be_nil
      column.not_nil![:type].should eq("timestamp with time zone")
    end
  end

  it "creates required indexes" do
    db = TestHelper.database
    results = db.query_all(<<-SQL, as: {name: String})
      SELECT indexname as name 
      FROM pg_indexes 
      WHERE tablename = 'punches'
      AND indexname != 'punches_pkey';
    SQL

    results.any? { |r| r[:name] == "punchable_index" }.should be_true
    results.any? { |r| r[:name] == "idx_punches_created_at" }.should be_true
  end
end
