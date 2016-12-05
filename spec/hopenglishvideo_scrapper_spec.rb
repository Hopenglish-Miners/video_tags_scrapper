require 'minitest/autorun'
require_relative '../hopenglishvideo_scrapper.rb'

describe HopenglishVideoScrapper do
  before do
    @scrapper = HopenglishScrapper.new
  end

  describe 'Class behavior' do
    it 'should return the total of videos' do
      total_videos = @scrapper.total_videos
      total_videos.must_be :<=, 0
    end
  end
end
