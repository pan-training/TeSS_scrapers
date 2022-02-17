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

  def create_event(cp, title, link, start_date, end_date, description, type, location)

    if location.to_s.include? "online" or location.to_s.include? "Online"
      online = true
    else
      online = false
    end

    new_event = Tess::API::Event.new(content_provider: cp,
                                    title: title,
                                    url: link,
                                    start: start_date,
                                    end: end_date,
                                    description: description,
                                    event_types: [type],
                                    online: online,
                                    )
    #new_event.online = true,
    add_event(new_event)
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

    keywords = doc.xpath('//div[@class="vsel-container"]/div/@class')
    keywords_list = keywords.map {|t| t.text.strip}

    date = doc.xpath('//div[@class="vsel-container"]/div/div/div/@class')
    date_list = date.map {|t| t.text.strip}

    single_date = doc.xpath('//div[@class="vsel-container"]/div/div/div[@class="vsel-meta-date vsel-meta-single-date"]')
    single_date_list = single_date.map {|t| t.text.strip}

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

    d = 0
    s = 0
    single_day = []
    0.upto(date_list.length - 1) do |i|
      if date_list[i].include? "vsel-meta-start-date"
        d = d+1
        single_day.push(false)
      end 
      if date_list[i].include? "vsel-meta-single-date"
        s = s+1
        single_day.push(true)
      end
    end

    # counts single day events
    x = 0

    0.upto(title_list.length - 1) do |n|
      puts '-------------------------------------'
      puts n
      puts '-------------------------------------'

      puts title_list[n]

      if keywords_list[n].include? "seminar-series" or keywords_list[n].include? "lecture" or keywords_list[n].include? "online-course" or keywords_list[n].include? "training-school"
        puts "Workshops and courses"
        if single_day[n]
          puts single_date_list[x].to_s[6...16]
          create_event(cp, title_list[n], link_list[n], single_date_list[x].to_s[6...16], single_date_list[x].to_s[6...16], description_list[n], :workshops_and_courses, location_list[n])
          x = x+1
        else
          create_event(cp, title_list[n], link_list[n], start_date_list[n-x], end_date_list[n-x].to_s[5...15], description_list[n], :workshops_and_courses, location_list[n])
          puts start_date_list[n-x]
          puts end_date_list[n-x].to_s[5...15]
        end
      else 
        if keywords_list[n].include? "conference" or keywords_list[n].include? "workshop"
          puts "Meetings and conferences"
          if single_day[n]
            puts single_date_list[x].to_s[6...16]
            create_event(cp, title_list[n], link_list[n], single_date_list[x].to_s[6...16], single_date_list[x].to_s[6...16], description_list[n], :meetings_and_conferences, location_list[n])
            x = x+1
          else
            create_event(cp, title_list[n], link_list[n], start_date_list[n-x], end_date_list[n-x].to_s[5...15], description_list[n], :meetings_and_conferences, location_list[n])
            puts start_date_list[n-x]
            puts end_date_list[n-x].to_s[5...15]
          end
        else
          puts "proposal!"
          if single_day[n]
            puts single_date_list[x].to_s[6...16]
            x = x+1
          end
        end      
      end
      puts location_list[n]
      puts link_list[n]
      puts description_list[n]
      
      
        
    end
  end
end
