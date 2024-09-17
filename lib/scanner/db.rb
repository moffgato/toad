require 'json'
require 'find'

module Scanner
  class DB
    def self.list
      entries = []

      Dir.glob(File.join(DB_DIR, '*.json')).each do |file|

        data = JSON.parse(File.read(file))
        filename = File.basename(file)
        entry = {}

        if filename.end_with?('_subdomains.json')

          entry[:domain] = data['domain']
          entry[:subdomain_count] = data['subdomains'].size

        else

          entry[:domain] = data['host']
          entry[:ports] = data['open_ports']
          entry[:link_count] = data['links'].values.flatten.size

        end

        entries << entry
      end

      combined_entries = entries.group_by { |e| e[:domain] }.map do |domain, records|
        combined = { domain: domain }
        records.each do |record|
          combined.merge!(record)
        end
        combined
      end

      puts JSON.pretty_generate(combined_entries)
    end

    def self.get(domain = nil, output_format = 'json')
      results = []

      Dir.glob(File.join(DB_DIR, '*.json')).each do |file|
        data = JSON.parse(File.read(file))
        filename = File.basename(file)
        file_domain = filename.sub(/_subdomains\.json$/, '').sub(/\.json$/, '')

        if domain.nil? || file_domain.match(/#{domain}/i)
          results << data
        end
      end

      puts JSON.pretty_generate(results)
    end


  end
end
