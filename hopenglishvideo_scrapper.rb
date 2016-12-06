require 'oga'
require 'open-uri'
require 'json'

class HopenglishScrapper
  HOME = 'https://www.hopenglish.com'
  SEARCH_ALL = 'search/show?query=i&page=&per_page='

  XPATH_GET_CARD = "//div[contains(@class,'summary')]"
  XPATH_GET_LAST_PAGER_LINK = "//div[contains(@class, 'pager')]//a[last()]"

  CARD_TITLE_XPATH = ".//img[contains(@class,'videoimg')]/@alt"
  CARD_TITLE_XPATH2 = ".//img[contains(@class,'phraseimg')]/@alt"
  CARD_TIME_XPATH = ".//time[contains(@class,'relativeTime')]"
  CARD_DATE_XPATH = ".//div[contains(@class,'view')]"
  CARD_LINK_XPATH = ".//a[contains(@class,'videolink')]/@href"
  CARD_LINK_XPATH2 = ".//a[contains(@class,'phraselink')]/@href"
  CARD_IMG_XPATH = ".//img[contains(@class,'videoimg')]/@src"
  CARD_IMG_XPATH2 = ".//img[contains(@class,'phraseimg')]/@src"
  MAP_VALUES = {
      "title" => [CARD_TITLE_XPATH , CARD_TITLE_XPATH2] ,
      "img" => [CARD_IMG_XPATH , CARD_IMG_XPATH2] ,
      "link" => [CARD_LINK_XPATH , CARD_LINK_XPATH2] ,
      "view_count" => [CARD_DATE_XPATH] ,
      "upload_date" => [CARD_TIME_XPATH]
  }

  def initialize
    puts "Getting html"
    @document = Oga.parse_html(open("#{HOME}/#{SEARCH_ALL}1"))
    @videos = []
  end

  def total_videos
    @videos.size
  end

  def go_to_page(page)
    @document = Oga.parse_html(open("#{HOME}/#{SEARCH_ALL}#{page}"))
  end

  def pages_cards_info
    elements = @document.xpath(XPATH_GET_CARD)
    (1...total_pages).each do |i|
      @document.xpath(XPATH_GET_CARD).map do |card|
        element = {}
        MAP_VALUES.each do |k, v|
          if card.xpath(v[0]).text.strip.empty?
            element[k] = card.xpath(v[1]).text.strip
          else
            element[k] = card.xpath(v[0]).text.strip
          end
        end
        @videos << element
        puts @videos.size
      end

      go_to_page(i+1)
    end
  end

  def videos_tags
    puts "Access card info"
    pages_cards_info
    puts "Access video details"
    result.to_json
  end

  def total_pages
    puts "Reading total pages"
    element = @document.xpath(XPATH_GET_LAST_PAGER_LINK).attribute("href")
    total = element[0].value.gsub("/search/show?query=i&page=&per_page=","")
    puts "Total Pages #{total}"
    total.to_i
  end
end

obj = HopenglishScrapper.new
obj.videos_tags
