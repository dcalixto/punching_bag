require "./spec_helper"

module TestHelper
  def self.database
    DB.open("postgres://postgres:postgres@localhost:5432/punching_bag_test")
  end

  def self.setup_test_db
    db = database
    db.exec "DROP TABLE IF EXISTS hits"
    db.exec "CREATE TABLE hits (id SERIAL PRIMARY KEY, punchable_type VARCHAR, punchable_id INTEGER, hits INTEGER DEFAULT 0, created_at TIMESTAMP, updated_at TIMESTAMP)"
  end
end
