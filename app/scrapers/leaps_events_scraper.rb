require 'tess_api_client'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class LeapsEventsScraper < Tess::Scrapers::Scraper

  def self.config
    {
        name: 'LEAPS Scraper',
        root_url: 'https://leaps-initiative.eu/',
        ical_path: '?post_type=tribe_events&tribe-bar-date=2022-01-10&ical=1'
    }
  end

  def scrape
    cp = Tess::API::ContentProvider.new(
        title: 'League of European Accelerator-based Photon Sources (LEAPS)',
        url: 'https://leaps-initiative.eu/',
        image_url: 'https://leaps-initiative.eu/wp-content/uploads/2019/11/cropped-LEAPS_logo_colour-e1573546128283.jpg',
        description: "LEAPS – the League of European Accelerator-based Photon Sources – is a strategic consortium initiated by the Directors of the Synchrotron Radiation and Free Electron Laser user facilities in Europe. Its primary goal is to actively and constructively ensure and promote the quality and impact of fundamental, applied and industrial research carried out at each facility to the greater benefit of European science and society.")


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