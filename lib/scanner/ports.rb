require 'tty-spinner'

module Scanner
  class PortScanner

    MAX_THREADS = 8

    def self.save_results(host, results)
      filename = File.join(DB_DIR, "#{sanitize_filename(host)}.json")
      File.open(filename, 'w') do |file|
        file.write(JSON.pretty_generate(results))
      end
    end

    def self.sanitize_filename(filename)
      filename.gsub(/[\/\?\%:\*\|"<> ]/, '_')
    end

    # host()
    def self.host(host, ports, output = 'table')

      spinner = TTY::Spinner.new("[:spinner] Scanning #{host} ...", format: :pulse_2)
      spinner.auto_spin

      ports_to_scan = ports.map(&:to_i)
      open_ports = ports_to_scan.select { |port| port_open?(host, port) }

      spinner.success("(Done)")

      results = {
        host: host,
        open_ports: open_ports,
        links: {},
      }

      if open_ports.any?
        puts "Open ports on #{host}: #{open_ports.join(', ')}" if output == 'table'
        open_ports.each do |port|
          links = WebScanner.scan_links(host, port, output)
          results[:links][port] = links
        end
      else
        puts "No open ports found on #{host}" if output == 'table'
      end

      if output == 'json'
        puts JSON.pretty_generate(results)
      end

      save_results(host, results)

    end

    # hosts()
    def self.hosts(hosts, ports, output = 'table')

      pool = Concurrent::FixedThreadPool.new(MAX_THREADS)
      mutex = Mutex.new
      results = []

      hosts.each do |host|
        pool.post do
          result = scan_host_result(host, ports, output)
          mutex.synchronize { results << result }
        end
      end

      pool.shutdown
      pool.wait_for_termination

      results.each do |result|
        save_results(result[:host], result)
      end

      if output == 'json'
        puts JSON.pretty_generate(results)
      end

    end

    def self.scan_host_result(host, ports, output)

      ports_to_scan = ports.map(&:to_i)
      open_ports = ports_to_scan.select { |port| port_open?(host, port) }

      results = { host: host, open_ports: open_ports, links: {}, }

      if open_ports.any?
        open_ports.each do |port|
          links = WebScanner.scan_links(host, port, output)
          results[:links][port] = links
        end
      end

      results
    end

    # tortuga?
    def self.port_open?(host, port, timeout = 1)
      Socket.tcp(host, port, connect_timeout: timeout) { true }
    rescue Errno::ECONNREFUSED, Errno::ETIMEOUT, SocketError
      false
    end

  end
end

