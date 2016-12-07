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

  VIDEO_DTL_SCRIPT_XPATH = "//div[contains(@class,'video_container')]//script"
  VIDEO_DTL_TAGS_XPATH = "//div[contains(@class,'tag')]//a"

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

  def go_to(relative_url)
    Oga.parse_html(open("#{HOME}#{relative_url}"))
  end

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
    get_video_details
  end

  def get_video_details
    @videos.each_with_index do |video, index|
      #For every video go to link and extract detail information
      video_page = go_to(video["link"])
      script = video_page.xpath(VIDEO_DTL_SCRIPT_XPATH).text.strip
      var_map = script_to_map(script)
      @videos[index]["postId"] = var_map["post_id"].to_i
      @videos[index]["start_t"] = var_map["start_t"].to_f
      @videos[index]["end_t"] = var_map["end_t"].to_f
      @videos[index]["youtubeId"] = var_map["vID"].to_s.gsub('"','')
      @videos[index]["tags"] = video_page.xpath(VIDEO_DTL_TAGS_XPATH).map { |v| v.text.strip}
    end
  end

  # Expect string with script text
  # Return a map object with var name as key and value
  def script_to_map(script)
    result = {}
    script.split(';').each do |s|
      pairs = s.strip.gsub("var",'').strip.split('=')
      result[pairs[0].strip] = pairs[1].strip
    end
    result
  end

  def total_pages
    element = @document.xpath(XPATH_GET_LAST_PAGER_LINK).attribute("href")
    total = element[0].value.gsub("/search/show?query=#{@query}&page=&per_page=","")
    total.to_i
  end

end
