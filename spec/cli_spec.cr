require "./spec_helper"

describe "CLI" do
  it "executes setup command" do
    result = PunchingBag::CLI.run("setup")
    result.should be_true
  end
end
