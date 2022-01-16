require 'open-uri'
require 'nokogiri'

class PanoscEventScraper < Tess::Scrapers::Scraper

  def self.config
  { 
      name: 'PaNOSC Event Scraper',
      root_url: 'https://www.panosc.eu/',
      index_path: 'events/',
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  end

  def scrape
    cp = add_content_provider(Tess::API::ContentProvider.new(title: "PaNOSC",
                                                             url: config[:root_url],
                                                             image_url: "https://eosc-portal.eu/sites/default/files/PANOSC_0.jpg",
                                                             description: "The Photon and Neutron Open Science Cloud (PaNOSC)

                                                            The Photon and Neutron Open Science Cloud (PaNOSC) is a European project for making FAIR data a reality in 6 European Research Infrastructures (RIs), developing and providing services for scientific data and connecting these to the European Open Science Cloud (EOSC).

                                                            ## Objectives

                                                            * Participate in the construction of the EOSC by linking with the e-infrastructures and other ESFRI clusters.
                                                            * Make scientific data produced at Europe’s major Photon and Neutron sources fully compatible with the FAIR principles.
                                                            * Generalise the adoption of open data policies, standard metadata and data stewardship from 15 photon and neutron RIs and physics institutes across Europe
                                                            * Provide innovative data services to the users of these facilities locally and the scientific community at large via the European Open Science Cloud (EOSC).
                                                            * Increase the impact of RIs by ensuring data from user experiments can be used beyond the initial scope.
                                                            * Share the outcomes with the national RIs who are observers in the proposal and the community at large to promote the adoption of FAIR data principles, data stewardship and the EOSC.",
                                                                                                                        content_provider_type: :project,
                                                            ))

    doc = Nokogiri::HTML(open(config[:root_url] + config[:index_path]))

    title = doc.xpath('//div[@class="inner"]/ul/li/a/h2/text()')
    title_list = title.map {|t| t.text.strip}

    date = doc.xpath('//div[@class="inner"]/ul/li/a/span[@class="event-date"]') #doc.css('span.event-date')
    date_list = date.map {|t| t.text.strip}

    url = doc.xpath('//div[@class="inner"]/ul/li/a/@href')
    url_list = url.map {|t| t.text.strip}

    description = doc.xpath('//div[@class="inner"]/ul/li/a/p/text()')
    description_list = description.map {|t| t.text.strip}

    0.upto(title_list.length - 1) do |n|
      day = Date.strptime(date_list[n].to_s, "%d/%m/%y")

      new_event = Tess::API::Event.new(content_provider: cp,
                                       title: title_list[n],
                                       url: url_list[n],
                                       start: day,
                                       end: day,
                                       description: description_list[n],
                                       event_types: [:workshops_and_courses]
                                      )
      add_event(new_event)

    end
  end
end
