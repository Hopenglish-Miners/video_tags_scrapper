require 'minitest/autorun'
require_relative 'spec_helper.rb'
require_relative '../hopenglishvideo_scrapper.rb'

describe HopenglishScrapper do
  before do
    VCR.insert_cassette "hopenglish"
    @scrapper = HopenglishScrapper.new("boss")
  end

  after do
    VCR.eject_cassette
  end

  describe 'Class behavior' do
    it 'should return the total of videos' do
      total_videos = @scrapper.total_videos
      total_videos > 0
    end

    it 'should return video elements' do
      videos = @scrapper.videos
      videos.size > 0
    end
  end

  describe 'Elements attributes' do
    it 'should have attribute title' do
      element = @scrapper.videos.sample
      element["title"].wont_be_empty
    end

    it 'should have attribute img' do
      element = @scrapper.videos.sample
      element["title"].wont_be_empty
    end

    it 'should have attribute link' do
      element = @scrapper.videos.sample
      element["link"] != ""
    end

    it 'should have attribute view_count' do
      element = @scrapper.videos.sample
      element["view_count"].wont_be_empty
    end

    it 'should have attribute upload_date' do
      element = @scrapper.videos.sample
      element["upload_date"].wont_be_empty
    end
  end

end
