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

    it 'get videos using sql injection code' do
    end

    it 'can create json file' do
    end

    it 'can save json file' do
    end

  end
end
