require 'httparty'
require 'rake_text'
require 'rails-html-sanitizer' 

class MoodleMaterialScraper < Tess::Scrapers::Scraper
  def self.config
  {
    name: 'Moodle',
    root_url: "http://pan-learning.org/moodle/webservice/rest/server.php",
    moodle_token: Tess::API.config['moodle_token'],
  }
  end

  def scrape
      cp = add_content_provider(Tess::API::ContentProvider.new(title: "PaN Training",
                                                             url: "https://pan-learning.org/",
                                                             image_url: "https://raw.githubusercontent.com/pan-training/training-catalogue/landing_page/new_design/PaN-training_color.png",
                                                             description: "PaN Training is the E-learning platform for the Photon and Neutron community. The platform has a long history and is also part of the EU-founded projects PaNOSC and ExPaNDS.

* The E-learning platform hosts free education and training for scientists and students.
* In the platform you will find courses on both the theory of photon and neutron scattering 
and how to use python code or software for data reduction and modelling.
* All content from our E-learning platform is also listed in this catalogue of PaN training materials.",
                                                             content_provider_type: :project,
                                                            ))
      query_params = {"wstoken" => config[:moodle_token], "moodlewsrestformat" => "json"}
      query_params_to_merge=query_params.merge({"wsfunction" => "core_course_get_courses"})
      response = HTTParty.get(config[:root_url], :query => query_params_to_merge)

      courses_array = []

      data = response.parsed_response
      data.each do |item|
        courses_array << {:id => item["id"], :fullname => item["fullname"],:first_summary => item["summary"]}
      end
      courses_array_two = []

      courses_array.each do |item|
        query_params_to_merge=query_params.merge({"wsfunction" => "core_course_get_contents", "courseid" => item[:id]}) 
        response = HTTParty.get(config[:root_url], :query => query_params_to_merge)
        summary_2 = response.parsed_response[0]["summary"]
        summary_3 = nil
        if response.parsed_response.length()>=2
           summary_3 = response.parsed_response[1]["summary"]
        end
        courses_array_two << {:id => item[:id], :fullname => item[:fullname], :first_summary => item[:summary], :second_summary => summary_2, :third_summary => summary_3}
      end


      courses_array_two.each do |item|
      #choose 2nd summary if it's not empty and if its longer than the first
      #choose 1st summary if it's not empty 
      #choose 3rd summary (needs to not be empty)
      #if theyre all empty (?possible?) then just write summary
      if (!item[:second_summary].nil?) 
       if(item[:first_summary].nil?)
       summary = item[:second_summary]
       elsif (item[:second_summary].length >= item[:first_summary].length)
       summary = item[:second_summary]
       else
       summary = item[:first_summary]
       end
      elsif (!item[:first_summary].nil?) 
       summary = item[:first_summary]
      elsif (!item[:third_summary].nil?) # true
       summary = item[:third_summary]
      else
       summary = "summary"
      end
      

      summary_sanitized = Rails::Html::FullSanitizer.new.sanitize(summary)
      #extract keywords out of the summary
      #9 is an arbitrary value, it can be changed to be higher so it's stricter
      rake = RakeText.new
      a = rake.analyse summary_sanitized, RakeText.SMART

      keywords_list = []

      a.each do |key, value|
          if value>9
          puts key, value
          keywords_list << key
          end
      end
      
      if keywords_list.length()>=1
      m = add_material(Tess::API::Material.new(title: item[:fullname],
                                               url: "https://pan-learning.org/moodle/course/view.php?id="+item[:id].to_s,
                                               short_description: summary,
                                               content_provider: cp,
                                               keywords: keywords_list,
                                                resource_type: ["Moodle course","e-learning"]
                                              ))      
      else

      m = add_material(Tess::API::Material.new(title: item[:fullname],
                                               url: "https://pan-learning.org/moodle/course/view.php?id="+item[:id].to_s,
                                               short_description: summary,
                                               content_provider: cp,
                                                resource_type: ["Moodle course","e-learning"]
                                              )) 
      
      end      
      end
  end
end

