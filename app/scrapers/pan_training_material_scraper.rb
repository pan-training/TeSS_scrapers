class PaNTrainingMaterialScraper < Tess::Scrapers::Scraper
  def self.config
  {
    name: 'PaN-learning',
    root_url: 'https://pan-learning.org',
    token: 'ZP2R5TIY5WEG6VKRATVR',
  }
  end

  def scrape
    cp = add_content_provider(Tess::API::ContentProvider.new( title: "PaN-learning.org",
                                                             url: config[:root_url],
                                                             image_url: "https://avatars.githubusercontent.com/u/63726080?s=200&v=4",
                                                             description: "PaN-learning.org is the e-learning platform from the joint projects PaNOSC and ExPaNDS.",
                                                             content_provider_type: :organisation
                                                            ))

      title = 'external generated test entry'
      link = 'http://www.hzdr.de'
      short_description = 'Only a test entry...'    

      # Create the material from the information above
      m = add_material(Tess::API::Material.new(title: title,
                                               url: link,
                                               short_description: short_description,
                                               content_provider: cp
                                               # scientific_topic_names: bio_keywords + comp_keywords,
                                               # keywords: bio_keywords + comp_keywords,
                                               # resource_type: presentation_type,
                                               # authors: [creator],
                                               # contributors: [presenter]
                                              ))

  end
end

