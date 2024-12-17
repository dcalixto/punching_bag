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
    setup_path = "./bin/punching_bag.cr"
    FileUtils.mkdir_p("./bin")
    FileUtils.mkdir_p("./db/migrations")

    unless File.exists?(setup_path)
      File.write(setup_path, <<-CODE)
        #!/usr/bin/env crystal
        require "punching_bag/cli"
        
        if ARGV.size > 0
          PunchingBag::CLI.run(ARGV[0])
        end
        CODE

      File.write("./db/migrations/create_punches.cr", CREATE_PUNCHES_MIGRATION)
      
      puts "Setup complete. Files created at:"
      puts "- #{setup_path}"
      puts "- ./db/migrations/create_punches.cr"
    else
      puts "Setup already completed."
    end

    # Run the migration
    DB::Migration.new(PunchingBag.db).up
    
    exit 0
  end

  def self.help
    puts "PunchingBag CLI Commands:"
    puts " setup - Initialize required files and directories"
  end

  private CREATE_PUNCHES_MIGRATION = <<-SQL
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
    SQL
end