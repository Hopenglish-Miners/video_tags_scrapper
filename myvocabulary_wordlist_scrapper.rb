require 'oga'
require 'open-uri'
require 'json'

class MyVocabularyScrapper
  HOME = 'https://myvocabulary.com'
  URL_CAT = 'dir-wordlist-word_list_alphabetic'

  XPATH_GET_CAT = "//table//td//a"
  XPATH_GET_WORD = "//td[contains(@valign,'top')]"

  def initialize
    @document = go_to "#{HOME}/#{URL_CAT}"
    @categories = []
    @file = FileSaver.new
  end

  def go_to(url)
    Oga.parse_html(open("#{url}",:read_timeout => 60))
  end

  def categories
    @categories = parse_categories
  end

  def categories_and_wordList
    categories
    @categories.map do |cat|
      doc = go_to "#{HOME}/#{cat.link}"
      doc.xpath(XPATH_GET_WORD).map do |words|
        words = words.text.split(',')
        if words.size > 0 and !words[0].include?(')')
          words.each { |w| cat.wordList.push(w.strip) }
        end
      end
      puts cat.name
      @file add_object cat
    end
    @categories
  end



  private

  def parse_categories
    result = []
    @document.xpath(XPATH_GET_CAT).map do |cat|
      newElement = Category.new
      newElement.name = cat.text.gsub(/\([^()]*\)/,"")
      newElement.link = cat.get 'href'
      result.push(newElement)
    end
    result
  end

end

class Category
  attr_accessor :name, :wordList, :link

  def initialize(params ={})
    @name = params.fetch(:name, '')
    @wordList = params.fetch(:wordList, [])
  end

  def to_json
    {name => wordList}.to_json
  end

end

class FileSaver

  def initialize
    @i = 0
    open_file
  end
  def open_file
    File.open("out/myvocabulary_categories.json","w") do |f|
      f.write("[]")
    end
  end

  def add_object obj
    File.truncate('out/myvocabulary_categories.json', File.size('out/myvocabulary_categories.json') - 1)

    open('out/myvocabulary_categories.json', 'a') do |f|
      f << "," if @i != 0
      f << obj.to_json
      f << "]"
    end

    @i = @i+1
  end
end


scrapper = MyVocabularyScrapper.new
result = scrapper.categories_and_wordList
scrapper.save(result)
