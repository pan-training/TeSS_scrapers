require 'tess_api_client'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class LaserlabEventsScraper < Tess::Scrapers::Scraper

  def self.config
    {
        name: 'Laserlab Scraper',
        root_url: 'https://www.laserlab-europe.eu/events-1/',
        ical_path: 'conferences/current-conferences-workshops/@@event_listing_ical?mode=future'
        
    }
  end

  def scrape
    cp = Tess::API::ContentProvider.new(
        title: ' Laserlab-Europe',
        url: 'https://www.laserlab-europe.eu',
        image_url: 'https://www.laserlab-europe.eu/images/laserlab_logo_rgb.jpg',
        description: "Laserlab-Europe has entered a new phase of its successful cooperation: the Consortium now brings together 35 leading institutions in laser-based inter-disciplinary research from 18 countries. Together with associate partners, Laserlab covers the majority of European member states. 24 laboratories offer access to their facilities for research teams from Europe and beyond, kindly supported by EC funding.
        Lasers and photonics, one of only five key enabling technologies identified by the European Union, are not only essential for the scientific future but also for the socio-economic security of any country. Given the importance of lasers and their applications in all areas of sciences, life sciences and technologies.")

    file = open_url(config[:root_url] + config[:ical_path])
    events = Icalendar::Event.parse(file.set_encoding('utf-8'))

    events.each do |event|
      begin
         add_event(Tess::API::Event.new(
                    content_provider: cp,
                    title: event.summary,
                    url: event.url,
                    start: event.dtstart,
                    end: event.dtend,
                    description: event.description,
                    organizer: '',
                    event_types: [:workshops_and_courses]
                  ))
      end
    end
  end
end