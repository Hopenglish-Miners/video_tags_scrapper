require 'oga'
require 'open-uri'
require 'json'

class HopenglishScrapper
  HOME = 'https://www.hopenglish.com'
  SEARCH_ALL = 'search/show?query=i'

  XPATH_GET_CARD = "//div[contains(@class,'summary')]"
  XPATH_GET_LAST_PAGER_LINK = "//div[contains(@class, 'pager')]//a[last()]"

  CARD_TITLE_XPATH = ".//img[contains(@class,'videoimg')]/@alt"
  CARD_TITLE_XPATH2 = ".//img[contains(@class,'phraseimg')]/@alt"
  CARD_TIME_XPATH = ".//time[contains(@class,'relativeTime')]"
  CARD_DATE_XPATH = ".//div[contains(@class,'view')]"
  CARD_LINK_XPATH = ".//a[contains(@class,'videolink')]"
  CARD_LINK_XPATH2 = ".//a[contains(@class,'phraselink')]"
  CARD_IMG_XPATH = ".//img[contains(@class,'videoimg')]/@src"
  CARD_IMG_XPATH2 = ".//img[contains(@class,'phraseimg')]/@src"
  MAP_VALUES = {
      "title" => [ CARD_TITLE_XPATH , CARD_TITLE_XPATH2] ,
      "img" => [ CARD_IMG_XPATH , CARD_IMG_XPATH2] ,
      "link" => [ CARD_LINK_XPATH , CARD_LINK_XPATH2] ,
      "view_count" => [ CARD_DATE_XPATH] ,
      "upload_date" => [ CARD_TIME_XPATH]
    }

  def initialize
    puts "Getting html"
    @document = Oga.parse_html(open("#{HOME}/#{SEARCH_ALL}"))
  end

  def total_videos
  end

  def videos_tags
    puts "Reading cards"
    elements = @document.xpath(XPATH_GET_CARD)
    result = []
    #(1..total_pages).each do |page|
      @document.xpath(XPATH_GET_CARD).map do |card|
        element = {}
        MAP_VALUES.each  |k, v| do
          if card.xpath(v[0]).text.strip.empty?
            element[k] = card.xpath(v[1]).text.strip
          else
            element[k] = card.xpath(v[0]).text.strip
        end
        puts element
        result << element
      end
    #end
    result.to_json
  end



  def total_pages
    puts "Reading total pages"
    element = @document.xpath(XPATH_GET_LAST_PAGER_LINK).attribute("href")
    element[0].value.gsub("/search/show?query=i&page=&per_page=","")
  end
end

obj = HopenglishScrapper.new
obj.videos_tags
