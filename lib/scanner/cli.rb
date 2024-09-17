require_relative 'db_cli'

module Scanner

  #
  class CLI < Thor
    desc 'host HOST', 'Scan a single host for open ports and links'
    option :ports, aliases: '-p', type: :array, default: [80], desc: 'Ports to scan'
    option :output, aliases: '-o', type: :string, default: 'table', desc: 'Output format: table or json'
    def host(host)
      PortScanner.host(host, options[:ports], options[:output])
    end

    desc 'hosts_file FILE', 'Scan multiple hosts from a file'
    option :ports, aliases: '-p', type: :array, default: [80, 443], desc: 'Ports to scan'
    option :output, aliases: '-o', type: :string, default: 'table', desc: 'Output format: table or json'
    def hosts_file(file)
      hosts = File.readlines(file).map(&:strip)
      PortScanner.hosts(hosts, options[:ports], options[:output])
    end

    desc 'subdomains DOMAIN', 'Fetch subdomains from crt.sh'
    option :delay, type: :numeric, default: 2, desc: 'Delay between requests to respect rate limit'
    option :output, aliases: '-o', type: :string, default: 'table', desc: 'Output format: table or json'
    def subdomains(domain)
      crt = CrtSh.new
      crt.subdomains(domain, options[:delay], options[:output])
    end

    desc 'db SUBCOMMAND ...ARGS', 'Database management commands'
    subcommand 'db', DBCLI

    desc 'version', 'Display the version'
    def version
      puts 'Scanner version 0.1.0'
    end

    default_task :help
  end

end
