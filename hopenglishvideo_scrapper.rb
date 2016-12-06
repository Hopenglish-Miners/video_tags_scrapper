require 'oga'
require 'open-uri'
require 'json'

class HopenglishScrapper
  HOME = 'https://www.hopenglish.com'

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

  def initialize(query)
    @query = query
    @document = Oga.parse_html(open("#{HOME}/search/show?query=#{query}&page=&per_page=1"))
    @videos = []
  end

  def total_videos
    videos.size
  end

  def videos
    if @videos.size > 0
      @videos
    else
      scrape_videos_tags
    end
  end

  private

  def go_to_page(page)
    @document = Oga.parse_html(open("#{HOME}/search/show?query=#{@query}&page=&per_page=#{page}"))
  end

  def pages_cards_info
    @videos = []
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
      end
      go_to_page(i+1)
    end
    @videos
  end

  def scrape_videos_tags
    pages_cards_info
  end

  def total_pages
    element = @document.xpath(XPATH_GET_LAST_PAGER_LINK).attribute("href")
    total = element[0].value.gsub("/search/show?query=#{@query}&page=&per_page=","")
    total.to_i
  end

end
