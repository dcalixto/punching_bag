require "./punching_bag"
require "file_utils"
require "db"
require "micrate"
require "pg"

module PunchingBag::CLI
  extend self

  def run(command : String)
    case command
    when "setup"
      setup
    else
      puts "Unknown command '#{command}'"
      help
    end
  end

  def setup
    migrations_path = File.join(File.dirname(__FILE__), "..", "db", "migrations")
    migration_file = File.join(migrations_path, "create_punches.sql")

    FileUtils.mkdir_p(migrations_path)

    unless File.exists?(migration_file)
      File.write(migration_file, CREATE_PUNCHES_MIGRATION)
      puts "Created migration at #{migration_file}"

      Micrate::DB.connect
      Micrate::Cli.run
      puts "Migration completed successfully"
    else
      puts "Migration already exists at #{migration_file}"
    end

    exit 0
  end

  def help
    puts "PunchingBag CLI Commands:"
    puts " setup - Initialize required files and directories"
  end
end

CREATE_PUNCHES_MIGRATION = <<-SQL
-- +micrate Up
CREATE TABLE punches (
  id BIGSERIAL PRIMARY KEY,
  punchable_type VARCHAR(255),
  punchable_id BIGINT,
  hits INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_punches_type_id ON punches(punchable_type, punchable_id);
CREATE INDEX idx_punches_created_at ON punches(created_at);

-- +micrate Down
DROP TABLE IF EXISTS punches;
SQL
