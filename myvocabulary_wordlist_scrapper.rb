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
      puts cat.wordList
    end
    @categories
  end

  def save(obj)
    File.open("/out/my_vocabulary.json","w") do |f|
      f.write(obj.to_json)
    end
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
    {:name => :wordList}.to_json
  end
end

class FileSaver

  def initialize
    @i = 0
    open_file
  end
  def open_file
    File.open("/out/video_tags.json","w") do |f|
      f.write("{\"videos\":[]}")
    end
  end

  def add_object obj
    File.truncate('/out/video_tags.json', File.size('/out/video_tags.json') - 2)

    open('video_tags.json', 'a') do |f|
      f << "," if @i != 0
      f << obj.to_json
      f << "]}"
    end

    @i = @i+1
  end
end
