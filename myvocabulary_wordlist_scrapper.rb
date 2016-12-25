require 'oga'
require 'open-uri'
require 'json'

class MyVocabularyScrapper
  HOME = 'https://myvocabulary.com/dir-wordlist-word_list_alphabetic'

  XPATH_GET_CAT = "//table//td//a"

  def initialize
    @document = Oga.parse_html(open("#{HOME}",:read_timeout => 60))
    @categories = []
  end

  def categories
    @categories = parse_categories
  end

  private

  def parse_categories
    result = []
    @document.xpath(XPATH_GET_CAT).map do |cat|
      newElement = Category.new
      newElement.name = cat.text.gsub(/\([^()]*\)/,"")
      result.push(newElement)
    end
    result
  end

end

class Category
  attr_accessor :name, :wordList

  def initialize(params ={})
    @name = params.fetch(:name, '')
    @wordList = params.fetch(:wordList, [])
  end
end
