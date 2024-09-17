require_relative 'db'

module Scanner
  class DBCLI < Thor
    desc 'list', 'list stored scan results'
    def list
      DB.list
    end

    desc 'get [DOMAIN]', 'Get scan results'
    option :output, aliases: '-o', type: :string, default: 'json', desc: 'Output format: json'
    def get(domain = nil)
      DB.get(domain, options[:output])
    end
  end
end
