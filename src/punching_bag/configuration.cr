module PunchingBag
  class Configuration
    class_property database_url : String = "postgres://localhost/punching_bag_test"
  end

  def self.configure
    yield Configuration
  end
end
