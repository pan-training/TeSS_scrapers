require 'open-uri'
require 'nokogiri'

class LightsourcesEventScraper < Tess::Scrapers::Scraper

  def self.config
  { 
      name: 'Lightsources.org Event Scraper',
      root_url: 'https://lightsources.org',
      index_path: '/for-users/events/',
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  end

  def scrape
    cp = add_content_provider(Tess::API::ContentProvider.new(title: "Lightsources.org",
                                                             url: config[:root_url],
                                                             image_url: "https://i0.wp.com/lightsources.org/wp-content/uploads/2019/02/2019Logo_LS_4c.png?resize=108%2C60&ssl=1",
                                                             description: "Lightsources.org is the result of a collaboration between communicators from light source facilities around the world. This platform groups 23 synchrotrons and 7 FEL facilities representing 24 organisations from 3 geographic zones: Europe / the Middle East, the Americas, and Asia / Australia.",
                                                             content_provider_type: :project,
                                                            ))

    doc = Nokogiri::HTML(open(config[:root_url] + config[:index_path]))

    # puts doc

    title = doc.xpath('//div[@class="vsel-container"]/div/div/h3/text()')
    title_list = title.map {|t| t.text.strip}

    start_date = doc.xpath('//div[@class="vsel-container"]/div/div/div[@class="vsel-meta-date vsel-meta-start-date"]') 
    start_date_list = start_date.map {|t| t.text.strip}

    end_date = doc.xpath('//div[@class="vsel-container"]/div/div/div[@class="vsel-meta-date vsel-meta-end-date"]') 
    end_date_list = end_date.map {|t| t.text.strip}

    location = doc.xpath('//div[@class="vsel-container"]/div/div/div[@class="vsel-meta-location"]') 
    location_list = location.map {|t| t.text.strip}

    link = doc.xpath('//div[@class="vsel-container"]/div/div/div[@class="vsel-meta-link"]/a/@href') 
    link_list = link.map {|t| t.text.strip}

    description = doc.xpath('//div[@class="vsel-container"]/div/div[@class="vsel-image-info vsel-image-info-right"]') 
    description_list = description.map {|t| t.text.strip}

    0.upto(title_list.length - 1) do |n|
      puts title_list[n]
      puts start_date_list[n]
      puts end_date_list[n]
      puts location_list[n]
      puts link_list[n]
      puts description_list[n]
      
    # day = Date.strptime(date_list[n].to_s, "%d/%m/%y")

      # new_event = Tess::API::Event.new(content_provider: cp,
      #                                  title: title_list[n],
      #                                  url: url_list[n],
      #                                  start: day,
      #                                  end: day,
      #                                  description: description_list[n],
      #                                  event_types: [:workshops_and_courses]
      #                                 )
      # add_event(new_event)

    end
  end
end
