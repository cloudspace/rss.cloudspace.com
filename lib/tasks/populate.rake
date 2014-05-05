require 'httparty'
require 'nokogiri'

class HTTParty::Basement; default_timeout 10; end

namespace :populate do

  def alexa_links(page_number = 1)
    url = "http://www.alexa.com/topsites/countries;#{page_number}/US"
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    nokogiri_sitelinks = doc.xpath('//a[starts-with(@href, "/siteinfo/")]')

    links = []

    nokogiri_sitelinks.each do |node|
      href = node[:href][10..-1]
      links.push("http://#{href}") unless !href
    end

    links
  end

  def technorati_links(page_number = 1)
    url = "http://technorati.com/blogs/top100/page-#{page_number}/"
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    nokogiri_sitelinks = doc.xpath('//td[@class="site-details"]/a[@class="offsite"]')

    links = []

    nokogiri_sitelinks.each do |node|
      href = node[:href]
      links.push(href) unless !href
    end
    
    links
  end

  def find_feed(url)
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    
    feeds = doc.xpath('//link[@rel="alternate"][@type="application/rss+xml"]').first
    feeds = doc.xpath('//link[@rel="alternate"][@type="application/atom+xml"]').first if !feeds

    return feeds[:href] if feeds

    nil
  end

  desc 'Scrapes Alexa for feeds'
  task :alexa => :environment do
    # real stop is 20
    (1..20).each do |i|
      puts "Gathering sites from Alexa page #{i}"

      begin
        site_links = alexa_links(i)
        feeds = []

        site_links.each do |site|
          puts "  Scraping #{site}"
          begin
            feed = find_feed(site)
            if feed
              puts '    Feed found... processing'
              Feed.find_or_generate_by_url(feed)
            end
          rescue
            puts "    Error scraping site"
          end
        end
      rescue
        puts "  Error scraping alexa"
      end
    end
  end

desc 'Scrapes Technorati for feeds'
  task :technorati => :environment do
    (1..100).each do |i|
      puts "Gathering sites from Alexa page #{i}"

      begin
        site_links = technorati_links(i)
        feeds = []

        site_links.each do |site|
          puts "  Scraping #{site}"
          begin
            feed = find_feed(site)
            if feed
              puts '    Feed found... processing'
              Feed.find_or_generate_by_url(feed)
            end
          rescue
            puts "    Error scraping site"
          end
        end
      rescue
        puts "  Error scraping alexa"
      end
    end
  end
end