require "./punching_bag"
require "file_utils"

class PunchingBag::CLI
  def self.run(command : String)
    case command
    when "setup"
      setup
    else
      puts "Unknown command '#{command}'"
      help
    end
  end

  def self.setup
    migrations_path = File.join(File.dirname(__FILE__), "..", "db", "migrations")
    migration_file = File.join(migrations_path, "create_punches.cr")

    FileUtils.mkdir_p(migrations_path)

    unless File.exists?(migration_file)
      File.write(migration_file, CREATE_PUNCHES_MIGRATION)
      puts "Created migration at #{migration_file}"

      # Create and run migration directly
      migration = CreatePunches.new
      migration.up
      puts "Migration completed successfully"
    else
      puts "Migration already exists at #{migration_file}"
    end

    exit 0
  end

  def self.help
    puts "PunchingBag CLI Commands:"
    puts " setup - Initialize required files and directories"
  end

  # Define the migration class right here
  class CreatePunches < DB::Migration
    def up
      execute <<-SQL
        CREATE TABLE punches (
          id BIGSERIAL PRIMARY KEY,
          punchable_type VARCHAR(255),
          punchable_id BIGINT,
          hits INTEGER DEFAULT 1,
          created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          starts_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          ends_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        );

        CREATE INDEX punchable_index 
        ON punches (punchable_type, punchable_id);

        CREATE INDEX created_at_index
        ON punches (created_at);
      SQL
    end

    def down
      execute <<-SQL
        DROP TABLE IF EXISTS punches;
        DROP INDEX IF EXISTS punchable_index;
        DROP INDEX IF EXISTS created_at_index;
      SQL
    end
  end
end
