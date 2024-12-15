module PunchingBag
  module CLI
    def self.run(command : String)
      case command
      when "setup"
        setup
      else
        "Unknown command: #{command}"
      end
    end

    private def self.setup
      # Add database setup logic here
      "Setup completed successfully"
    end
  end
end
