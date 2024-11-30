require "./punching_bag"

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

    unless File.exists?(setup_path)
      File.write(setup_path, <<-CODE)
      #!/usr/bin/env crystal
    
      require "punching_bag/cli"
    
      if ARGV.size > 0
        PunchingBag::CLI.run(ARGV[0])
      end
    CODE
      puts "Setup complete. File created at #{setup_path}"
    else
      puts "Setup already completed."
    end

    # Exit after setup to prevent further execution errors
    exit 0
  end

  def self.help
    puts "PunchingBag CLI Commands:"
    puts "  setup - Initialize required files and directories"
  end
end
