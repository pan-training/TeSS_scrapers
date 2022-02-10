require 'open-uri'
require 'nokogiri'

class LensEventScraper < Tess::Scrapers::Scraper

  def self.config
  { 
      name: 'Lens Event Scraper',
      root_url: 'https://www.lens-initiative.org/',
      index_path: '/events/',
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  end

  def scrape
    cp = add_content_provider(Tess::API::ContentProvider.new(title: "League of advanced European Neutron Sources (LENS)",
                                                             url: config[:root_url],
                                                             image_url: "http://bivi.co/sites/default/files/logo.png",
                                                             description: "The League of advanced European Neutron Sources (LENS) has the not-for-profit purpose of promoting the cooperation and projects between European-level neutron infrastructure providers that offer a transnational user programme. The individual members remain independent but together through LENS join forces to support and strengthen European neutron science by creating an effective, collaborating eco-system of neutron facilities.
                                                             LENS places emphasis on the relationship between user communities and funding organisations, continuous improvement of source facilities, optimising resources between and aligning policies among partners – all to ensure excellence to the communities they serve.",
                                                             content_provider_type: :project,
                                                            ))

    doc = Nokogiri::HTML(open(config[:root_url] + config[:index_path]))

    post_title = 'div.upl-post-title a'
    title_date = doc.css(post_title)
    title_date_list = title_date.map {|t| t.text.strip}
    
    links = doc.css(post_title).map { |link| link['href'] }

    description_css = 'div.upl-post-excerpt'
    descriptions = doc.css(description_css)
    text = descriptions.map {|t| t.text.strip}
    
    0.upto(title_date.length - 1) do |n|
      title_date = title_date_list[n].split(',')

      title = ""
      0.upto(title_date.length - 2) do |i|
        title +=  title_date[i]
      end
      date = title_date[title_date.length-1]

      date_array = date.split("-")
       
      if date_array.include? [226, 128, 147]
        puts "More than one month!!!!"
      end
      

      puts date_array[0]

      if date_array.length == 3 then
        end_date = start_date
      else
      end_date = date_array[-2]
      end
      start_date = date_array[-3]
      #year = end_date[-1]

      # 2022-04-11 22:00

      puts "Title:"
      puts title
      puts "URL:"
      puts links[n]
      puts "Start Date:"
      puts start_date
      #puts DateTime.parse(start_date.to_s + year)
      puts "End Date:"
      puts end_date
      #puts DateTime.parse(end_date)
      puts "year"
      #puts year
      puts "Text"
      puts  text[n]


      
      #new_event = Tess::API::Event.new(content_provider: cp,
      #                                 title: title,
      #                                 url: links[n],
      #                                 start: start,
      #                                 end: stop,
      #                                 description: text[n],
      #                                 event_types: [:workshops_and_courses]
      #                                )
      #add_event(new_event)


      puts "- in Bytes: " + "-".bytes.to_s
      puts "– in Bytes: " + "–".bytes.to_s
    end
  end
end