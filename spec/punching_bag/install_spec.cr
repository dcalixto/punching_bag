require "../spec_helper"

describe "PunchingBag Installation" do
  it "should create punches table with correct schema" do
    DB.open(PunchingBag::Configuration.database_url) do |db|
      db.query("SELECT sql FROM sqlite_master WHERE type='table' AND name='punches'") do |rs|
        rs.move_next
        schema = rs.read(String)
        schema.should contain("id INTEGER PRIMARY KEY")
        schema.should contain("punchable_id INTEGER NOT NULL")
        schema.should contain("punchable_type TEXT NOT NULL")
        schema.should contain("starts_at DATETIME NOT NULL")
        schema.should contain("ends_at DATETIME NOT NULL")
        schema.should contain("average_time DATETIME NOT NULL")
        schema.should contain("hits INTEGER DEFAULT 1")
      end
    end
  end

  it "should not fail when table already exists" do
    2.times do
      DB.open(PunchingBag::Configuration.database_url) do |db|
        db.exec "CREATE TABLE IF NOT EXISTS punches (
          id INTEGER PRIMARY KEY,
          punchable_id INTEGER NOT NULL,
          punchable_type TEXT NOT NULL,
          starts_at DATETIME NOT NULL,
          ends_at DATETIME NOT NULL,
          average_time DATETIME NOT NULL,
          hits INTEGER DEFAULT 1
        )"
      end
    end
  end

  it "should allow inserting records into created table" do
    DB.open(PunchingBag::Configuration.database_url) do |db|
      db.exec(
        "INSERT INTO punches (punchable_id, punchable_type, starts_at, ends_at, average_time, hits)
         VALUES (?, ?, ?, ?, ?, ?)",
        1, "Post", Time.utc, Time.utc, Time.utc, 1
      )

      db.scalar("SELECT COUNT(*) FROM punches").should eq(1)
    end
  end
end
