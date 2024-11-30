require "../src/punching_bag"
require "spec"

describe PunchingBag do
  it "tracks and retrieves hits correctly" do
    bag = PunchingBag.new
    bag.clear # Ensure a clean slate

    # Insert data for the test
    bag.punch("Post", 1, 2)
    bag.punch("Post", 1, 1)

    # Debugging: Print all records
    all_hits = bag.most_hit(Time.utc - 1.year) # Retrieve all hits for debugging
    pp all_hits

    # Test expectation
    bag.total_hits("Post", 1).should eq(3)
  end
  it "calculates average time correctly for multiple punches" do
    bag = PunchingBag.new
    bag.clear

    now = Time.utc
    bag.punch("Article", 1, 2, now - 2.days)
    bag.punch("Article", 1, 3, now - 1.day)

    avg_time = bag.average_time("Article", 1)
    expected_time = Time.unix(((now - 2.days).to_unix * 2 + (now - 1.day).to_unix * 3) // 5)
    avg_time.should eq(expected_time)
  end

  it "returns UTC time when no punches exist" do
    bag = PunchingBag.new
    bag.clear
    avg_time = bag.average_time("Post", 1)
    (avg_time - Time.utc).total_milliseconds.abs.should be < 1
  end

  it "calculates average time for single punch" do
    bag = PunchingBag.new
    bag.clear

    specific_time = Time.utc(2023, 1, 1, 12, 0, 0)
    bag.punch("Post", 1, 1, specific_time)

    avg_time = bag.average_time("Post", 1)
    avg_time.should eq(specific_time)
  end

  it "retrieves most hit items within a time range" do
    bag = PunchingBag.new
    bag.clear
    bag.punch("Post", 1, 5)
    bag.punch("Post", 2, 3)
    bag.punch("Comment", 1, 1)
    since = Time.utc - 1.day
    most_hit = bag.most_hit(since)
    pp most_hit # Inspect the query result
    most_hit[0]["punchable_id"].should eq(1)
    most_hit[0]["total_hits"].should eq(5)
  end
end
