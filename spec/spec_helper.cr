require "spec"
require "../src/punching_bag"
require "./test_helper"

PunchingBag.configure do |config|
  config.database_url = "postgres://postgres:postgres@localhost:5432/punching_bag_test"
end

Spec.before_each do
  TestHelper.database.exec "DROP TABLE IF EXISTS punches"

  TestHelper.database.exec <<-SQL
    CREATE TABLE punches (
      id BIGSERIAL PRIMARY KEY,
      punchable_type VARCHAR(255),
      punchable_id BIGINT,
      hits INTEGER DEFAULT 1,
      created_at TIMESTAMP WITH TIME ZONE,
      starts_at TIMESTAMP WITH TIME ZONE,
      ends_at TIMESTAMP WITH TIME ZONE
    )
  SQL

  TestHelper.database.exec <<-SQL
    CREATE INDEX punchable_index ON punches (punchable_type, punchable_id)
  SQL

  TestHelper.database.exec <<-SQL
    CREATE INDEX idx_punches_created_at ON punches (created_at)
  SQL
end
Spec.after_suite do
  TestHelper.database.close
end
