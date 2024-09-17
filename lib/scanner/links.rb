require 'net/http'
require 'openssl'
require 'nokogiri'
require 'terminal-table'

module Scanner
  class WebScanner

    def self.scan_links(host, port, output_format = 'table')

      uri = build_uri(host, port)
      response = fetch_response(uri)

      return [] unless response

      links = extract_links(response.body)
      if output_format == 'json'
        links
      else

        if links.any?
          puts "Found links on #{uri}:"
          table = Terminal::Table.new do |t|
            t.headings = ['Links']
            links.each { |link| t.add_row([link]) }
          end
          puts table
        else
          puts "No links found on #{uri}."
        end

        links
      end
    end

    def self.build_uri(host, port)
      scheme = [443, '443'].include?(port) ? 'https' : 'http'
      URI("#{scheme}://#{host}:#{port}/")
    end

    def self.fetch_response(uri, limit = 10)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.open_timeout = 7
      http.read_timeout = 15

      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = 'Pneumonoultramicroscopicsilicovolcanoconiosis/4.2'

      res = http.request(req)

      # logic for succes, redirects etc
      case res
      when Net::HTTPSuccess
        res
      when Net::HTTPRedirection
        location = res['location']
        new_uri = URI.parse(location)
        new_uri = uri + location unless new_uri.is_a?(URI::HTTP)
        puts "Redirected to #{new_uri}"
        fetch_response(new_uri, limit - 1)
      else
        puts "Failed to retrieve content from #{uri}: #{response_code} #{response.message}"
        nil
      end

    rescue StandardError => e
      puts "Failed to retrieve content from #{uri}: #{e.message}"
      nil
    end

    def self.extract_links(html)
      doc = Nokogiri::HTML(html)
      doc.css('a[href]').map { |link| link['href'] }.compact.uniq
    end
  end
end



