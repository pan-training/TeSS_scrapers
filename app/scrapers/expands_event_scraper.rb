require 'open-uri'
require 'nokogiri'

class ExPaNDSEventScraper < Tess::Scrapers::Scraper

  def self.config
  { 
      name: 'ExPaNDS Event Scraper',
      root_url: 'https://expands.eu/',
      index_path: 'newsevents/',
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  end

  def scrape
    cp = add_content_provider(Tess::API::ContentProvider.new(title: "ExPaNDS",
                                                             url: config[:root_url],
                                                             image_url: "https://expands.eu/wp-content/uploads/2021/10/cloud-Oct-2021.png?w=640",
                                                             description: "ExPaNDS is the European Open Science Cloud (EOSC) Photon and Neutron Data Service.

                                                            The ambitious ExPaNDS project is a collaboration between 10 national Photon and Neutron Research Infrastructures (PaN RIs) as well as EGI. The project aims to deliver standardised, interoperable, and integrated data sources and data analysis services for Photon and Neutron facilities.

                                                            ## Objectives

                                                            ### FAIR data principles

                                                            ExPaNDS’s ambition is to coordinate activities to enable national PaN RIs to make the majority of their data open following the FAIR principles; Findable, Accessible, Interoperable, and Reusable.

                                                            ### Harmonising EOSC services

                                                            ExPaNDS will allow data to be tailored to the user’s needs, and will harmonise their efforts to migrate data analysis workflows to EOSC platforms, allowing them to be shared in a uniform way.",
                                                            content_provider_type: :project,
                                                            ))

    doc = Nokogiri::HTML(open(config[:root_url] + config[:index_path]))

    title = doc.xpath('//h1[@class="entry-title"]/a/text()')
    title_list = title.map {|t| t.text.strip}

    #date = doc.xpath('//div[@class="inner"]/ul/li/a/span[@class="event-date"]') #doc.css('span.event-date')
    #date_list = date.map {|t| t.text.strip}

    url = doc.xpath('//a[@class="more-link"]/@href')
    url_list = url.map {|t| t.text.strip}

    description = doc.xpath('//div[@class="entry-summary"]/p/text()')
    description_list = description.map {|t| t.text.strip}

    0.upto(title_list.length - 1) do |n|

      doc = Nokogiri::HTML(open(url_list[n]))
      puts title_list[n]
      puts url_list[n]
      puts description_list[n]
      puts doc.xpath('//div[@class="entry-content"]/text()')

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