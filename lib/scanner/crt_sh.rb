require 'net/http'
require 'json'
require 'terminal-table'
require 'fileutils'

module Scanner
  class CrtSh

    CRT_SH_URL = 'https://crt.sh'
    DB_DIR = File.expand_path('~/.toad/db')

    FileUtils.mkdir_p(DB_DIR) unless Dir.exist?(DB_DIR)

    def subdomains(domain, delay = 2, output_format = 'table')
      query = URI.encode_www_form(q: "%.#{domain}", output: 'json')
      url = URI("#{CRT_SH_URL}?#{query}")
      response = fetch_response(url)

      if response.is_a?(Net::HTTPSuccess)
        subdomains = parse_subdomains(response.body)

        results = {
          domain: domain,
          subdomains: subdomains
        }
        save_results(domain, results)

        if output_format == 'json'
          puts JSON.pretty_generate(results)
        else
          if subdomains.any?
            puts "Subdomains for #{domain}:"
            table = Terminal::Table.new do |t|
              t.headings = ['Subdomains']
              subdomains.each { |subdomain| t.add_row([subdomain]) }
            end
            puts table
          else
            puts "No subdomains found for #{domain}."
          end
        end
      else
        puts "Failed to fetch subdomains from crt.sh: #{response.code} #{response.message}" if output_format == 'table'
      end

      sleep(delay)
    end

    private

    def save_results(domain, results)
      filename = File.join(DB_DIR, "#{sanitize_filename(domain)}_subdomains.json")
      File.open(filename, 'w') do |file|
        file.write(JSON.pretty_generate(results))
      end
    end

    def sanitize_filename(filename)
      filename.gsub(/[\/\?\%:\*\|"<> ]/, '_')
    end

    def fetch_response(url)
      Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(url)
        http.request(request)
      end
    rescue StandardError => e
      puts "Error fetching data from crt.sh: #{e.message}" if @output_format == 'table'
      nil
    end

    def parse_subdomains(body)
      data = JSON.parse(body)
      data.map { |entry| entry['name_value'] }
          .flat_map { |name| name.split("\n") }
          .map(&:strip)
          .uniq
          .select { |name| valid_domain?(name) }
    end

    def valid_domain?(domain)
      domain =~ /\A[\w\.\-]+\z/
    end
  end
end

