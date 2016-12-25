require 'minitest/autorun'
require_relative 'spec_helper.rb'
require_relative '../hopenglishvideo_scrapper.rb'

describe 'My Vocabulary Category' do
  before do
    VCR.insert_cassette 'myvocabulary'
  end

  after do
    VCR.eject_cassette
  end

  it 'should return a list of categories bigger than 0' do
    scrapper = MyVocabularyScrapper.new
    scrapper.categories.size > 0
  end

  it 'should have a name attribute' do
    scrapper = MyVocabularyScrapper.new
    scrapper.categories.each {|cat| cat.name.wont_be_empty}
  end

  it 'should have a link attribute' do
    scrapper = MyVocabularyScrapper.new
    scrapper.categories.each {|cat| cat.link.wont_be_empty}
  end
end

describe 'My Vocabulary Sub Category' do
  before do
    VCR.insert_cassette 'myvocabulary_dtl'
  end

  after do
    VCR.eject_cassette
  end

  it 'should check that all categories have a attribute wordList that is not empty' do
    scrapper = MyVocabularyScrapper.new
    scrapper.categories_and_wordList.size > 0
  end

end
