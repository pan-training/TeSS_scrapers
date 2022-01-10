require_relative 'lib/tess_scrapers'
require 'net/smtp'

log = 'log/scrapers.log' # The log file for this script, just mentions which scrapers are run.
output = 'log/scrapers.out' # The log file for scraper output. Says how many events etc. were scraped. Need to logrotate this, will be big!
email = ARGV[0] != 'no_email' rescue true

scrapers = [
  # PaNTrainingMaterialScraper
  # LensEventScraper,
  LaserlabEventsScraper,
  LeapsEventsScraper
]


options = { output_file: output, debug: false, verbose: false, offline: false, cache: false } # Live!
#options = { output_file: output, debug: true, verbose: true, offline: false, cache: true } # Testing

failed_scrapers = []

begin
  # Open log file
  log_file = File.open(log, 'w')

  scrapers.each do |scraper_class|
    log_file.puts "Running #{scraper_class}"
    begin
      scraper_class.new(options).run
    rescue => e
      log_file.puts e.message
      log_file.puts e.backtrace.join("\n")
      failed_scrapers << [scraper_class, e]
    end
  end

  if email && failed_scrapers.length > 0
    message = <<MESSAGE_END
From: TeSS <pan-training@hzdr.de>
To: TeSS <pan-training@hzdr.de>
Subject: Scraper Failure (#{failed_scrapers.map { |e| e[0] }.join(', ')})

It would seem that the following scrapers have failed to run:

#{failed_scrapers.map { |e| "#{e[0]}: #{e[1].message}\n\t#{e[1].backtrace.join("\n\t")}" }.join("\n\n")}

MESSAGE_END

    begin
      Net::SMTP.start('localhost') do |smtp|
        smtp.send_message message, 'pan-training@hzdr.de'
      end
    rescue => e
      puts "Could not email: #{message} | #{e}"
    end
  end

  log_file.puts 'Done'
ensure
  log_file.close
end
