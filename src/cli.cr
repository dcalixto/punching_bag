require "./punching_bag"
require "file_utils"
require "../../db/migrations/create_punches"

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
    migrations_path = "./db/migrations"
    FileUtils.mkdir_p(migrations_path)

    CreatePunches.new.up
    puts "Migration completed successfully"

    exit 0
  end

  def self.help
    puts "PunchingBag CLI Commands:"
    puts "setup - Initialize required files and directories"
  end
end
