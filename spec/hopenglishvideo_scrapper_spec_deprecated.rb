require 'minitest/autorun'
require_relative 'spec_helper.rb'
require_relative '../hopenglishvideo_scrapper.rb'

describe HopenglishScrapper do
  before do
    VCR.use_cassette("hopenglish") do
      @scrapper = HopenglishScrapper.new("boss")
    end
  end

  describe 'Simple Cards Behavior' do
    before do
      VCR.insert_cassette 'hopenglish'
    end

    after do
      VCR.eject_cassette
    end

    it 'should return the total of videos' do
      total_videos = @scrapper.total_videos
      total_videos > 0
    end

    it 'should return video elements' do
      videos = @scrapper.vides_without_detail
      videos.size > 0
    end

    it 'should have attribute title' do
      element = @scrapper.vides_without_detail.sample
      element["title"].wont_be_empty
    end

    it 'should have attribute img' do
      element = @scrapper.vides_without_detail.sample
      element["title"].wont_be_empty
    end

    it 'should have attribute link' do
      element = @scrapper.vides_without_detail.sample
      element["link"] != ""
    end

    it 'should have attribute view_count' do
      element = @scrapper.vides_without_detail.sample
      element["view_count"].wont_be_empty
    end

    it 'should have attribute upload_date' do
      element = @scrapper.vides_without_detail.sample
      element["upload_date"].wont_be_empty
    end

  end


  describe 'Getting details information' do
    before do
      VCR.insert_cassette 'hopenglish_dtl'
    end

    after do
      VCR.eject_cassette
    end

    it 'should have postId value' do
      element = @scrapper.videos.sample
      element["postId"] > 0
    end
    # it 'should have start time value' do
    #   element = @scrapper.videos.sample
    #   element["start_t"] >= 0 or element["start_t"] == null
    # end
    # it 'should have end time value' do
    #   element = @scrapper.videos.sample
    #   element["end_t"] >= 0 or element["end_t"] == null
    # end
    # it 'should have youtube id' do
    #   element = @scrapper.videos.sample
    #   element["youtubeId"].wont_be_empty
    # end
    it 'should have tags' do
      element = @scrapper.videos.sample
      element["tags"].size >= 0
    end

    it 'should have wordlist' do
      element = @scrapper.videos.sample
      element["wordList"].size >= 0
    end

    it 'show have sentences' do
      element = @scrapper.videos.sample
      element["sentences"].size >=0
    end
  end
end
