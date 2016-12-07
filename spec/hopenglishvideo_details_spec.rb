require 'minitest/autorun'
require_relative 'spec_helper.rb'
require_relative '../hopenglishvideo_scrapper.rb'

describe HopenglishScrapper do
  before do
    VCR.insert_cassette "hopenglish_dtl"
    @scrapper = HopenglishScrapper.new("boss")
  end

  after do
    VCR.eject_cassette
  end

  describe 'Getting details information' do
    it 'should have postId value' do
      element = @scrapper.videos.sample
      element["postId"] > 0
    end
    it 'should have start time value' do
      element = @scrapper.videos.sample
      element["start_t"] >= 0
    end
    it 'should have end time value' do
      element = @scrapper.videos.sample
      element["end_t"] >= 0
    end
    it 'should have youtube id' do
      element = @scrapper.videos.sample
      element["youtubeId"].wont_be_empty
    end
    it 'should have tags' do
      element = @scrapper.videos.sample
      element["tags"].size >= 0
  end
end
