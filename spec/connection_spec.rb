require 'minitest/autorun'
require_relative '../scrapper.rb'

describe Scrapper do
  before do
    @scrapper = Scrapper.new
  end
  describe "scrapper connection" do
    it "can visit index page" do
      home = @scrapper.visit('/')
      home.status_code = 200
    end
  end
end
