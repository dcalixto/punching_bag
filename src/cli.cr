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
      
      load_migration(migration_file)
      CreatePunches.new.up
      puts "Migration completed successfully"
    else
      puts "Migration already exists at #{migration_file}"
    end
    
    exit 0
  end

  private def self.load_migration(file_path)
    require file_path
  end

  def self.help
    puts "PunchingBag CLI Commands:"
    puts " setup - Initialize required files and directories"
  end
end