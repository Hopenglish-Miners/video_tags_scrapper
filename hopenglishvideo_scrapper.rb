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
  VIDEO_DTL_SENTENCES_XPATH = "//div[contains(@id,'tabs-1')]//div[contains(@class,'content')]//p//span"
  VIDEO_DTL_SENTENCES_XPATH2 = "//div[contains(@class,'phrases-content')]//p"

  def initialize(query)
    @query = query
    @document = Oga.parse_html(open("#{HOME}/search/show?query=#{query}&page=&per_page=1",:read_timeout => 60))
    @videos = []
  end

  def total_videos
    vides_without_detail.size
  end

  def vides_without_detail
    if @videos.size > 0
      @videos
    else
      scrape_videos_simple_cards
    end
  end

  def videos
    if @videos.size > 0
      @videos
    else
      scrape_videos_simple_cards
      scrape_videos_details_cards
    end
  end

  private

  def go_to(relative_url)
    Oga.parse_html(open("#{HOME}#{relative_url}",:read_timeout => 60))
  end

  def go_to_page(page)
    @document = Oga.parse_html(open("#{HOME}/search/show?query=#{@query}&page=&per_page=#{page}",:read_timeout => 60))
  end

  def pages_cards_info
    @videos = []
    total = total_pages
    # total = 5
    (1...total).each do |i|
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
      puts "Total General Cards #{@videos.size}. Page #{i} of #{total}"
      go_to_page(i+1)
    end
    @videos
  end

  def scrape_videos_simple_cards
    puts "INit Scraper"
    pages_cards_info
    File.open("out/video_simple_cards.json","w") do |f|
      f.write(@videos.to_json)
    end
  end

  def scrape_videos_details_cards
    file = File.read("out/video_simple_cards.json")
    @videos = JSON.parse(file)
    #puts "Init to get Details"
    get_video_details
  end

  def get_video_details
    f = FileSaver.new
    @videos.each_with_index do |video, index|
      #For every video go to link and extract detail information
      video_page = go_to(video["link"])
      script = video_page.xpath(VIDEO_DTL_SCRIPT_XPATH).text.strip
      var_map = script_to_map(script)
      @videos[index]["postId"] = var_map["post_id"].to_i
      @videos[index]["start_t"] = var_map["start_t"]
      @videos[index]["end_t"] = var_map["end_t"]
      @videos[index]["youtubeId"] = var_map["vID"].to_s.gsub('"','')
      @videos[index]["tags"] = video_page.xpath(VIDEO_DTL_TAGS_XPATH).map { |v| v.text.strip}
      @videos[index]["sentences"] = video_page.xpath(VIDEO_DTL_SENTENCES_XPATH).map {|v| v.text.strip}
      if @videos[index]["sentences"].size == 0
        @videos[index]["sentences"] = video_page.xpath(VIDEO_DTL_SENTENCES_XPATH2).map {|v| v.text.strip[/[^\n]+/]}
      end
      @videos[index]["wordList"] = extract_words @videos[index]["sentences"]
      f.add_object @videos[index]
      puts "Added details for element #{index+1} of #{@videos.size}"
    end
  end

  def extract_words(sentences)
    words = []
    if sentences
      sentences.each do |s|
        if s
          words.push(*s.split(/[^\w'-]+/))
        end
      end
    end
    words
  end

  # Expect string with script text
  # Return a map object with var name as key and value
  def script_to_map(script)
    result = {}
    script.split(';').each do |s|
      pairs = s.strip.gsub("var",'').strip.split('=')
      result[pairs[0].strip] = pairs[1] ? pairs[1] : ""
    end
    result
  end

  def total_pages
    element = @document.xpath(XPATH_GET_LAST_PAGER_LINK).attribute("href")
    total = element[0].value.gsub("/search/show?query=#{@query}&page=&per_page=","")
    total.to_i
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

# scrapper = HopenglishScrapper.new('I')
# scrapper.videos
