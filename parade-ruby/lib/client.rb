require_relative './server'
require 'net/http'
require 'json'

module Paradise
  ##
  # Represents a Paradise client interface
  class Client
    def initialize(conn)
      @connections = []
      connect conn
    end

    def connect(conn)
      @connections << conn
      connection.greet
    end

    def disconnect
      conn = @connections.pop
      conn.disconnect
      raise Disconnected if @connections.empty?
    end

    def clear_and_connect_to(new_conn)
      @connections.each(&:disconnect)
      @connections = [new_conn]
      connection.greet
    end

    def query(*args)
      result = connection.query(*args)
      process_host result[:host] if result.key? :host
      res = { text: result.fetch(:text, '').to_s }
      res[:error] = true if result.fetch(:error, false)
      res
    end

    def connection
      raise Disconnected if @connections.empty?

      @connections.last
    end

    private

    def process_host(host)
      case host
      when 'parade://disconnect'
        disconnect
      when 'parade://local'
        # TODO
        raise NotImplementedError
      else
        # TODO
        raise NotImplementedError
        # connect HTTPConnection.new host
      end
    end

    class Disconnected < StandardError
    end

    ##
    # Represents the connection between a +Client+ and a +Server+. This is an
    # abstract class.
    class Connection
      def initialize(host, vessel = nil)
        @host   = host
        @vessel = vessel
      end

      ##
      # Greet the host and obtain a vessel ID
      def greet
        raise NotImplementedError
      end

      ##
      # Notify the host about disconnection
      def disconnect
        raise NotImplementedError
      end

      ##
      # Send a query to the host
      def query(_string)
        raise NotImplementedError
      end

      attr_accessor :vessel
      attr_reader   :host
    end

    class LocalConnection < Connection
      def initialize(vessel = nil, world_path = nil)
        @world_path = world_path
        world = if File.exist? @world_path
                  Paradise::World.load File.open(FILENAME, 'r')
                else
                  Paradise::World.default
                end
        host = Paradise::Server.new world
        super(host, vessel)
      end

      def greet
        res = @host.greet
        @vessel = res[:vessel_id]
      end

      def disconnect
        File.open(@world_path, 'w') do |f|
          @host.world.dump f
        end
      end

      def query(string)
        result = host.query @vessel, string
        @vessel = result[:vessel] if result.key? :vessel
        result
      end
    end

    class HTTPConnection < Connection
      def greet
        res = get_res '/greet'
        @vessel = res[:vessel]
      end

      def disconnect
        res = get_res '/disconnect'
      end

      def query(string)
        res = get_res '/query', vessel: @vessel, query: string
        @vessel = res[:vessel] if res.key? :vessel
        res
      end

      private

      def get_res(page, params = {})
        uri = URI(@host + page)
        uri.query = URI.encode_www_form params unless params.empty?
        res = Net::HTTP.get_response uri
        JSON.parse res.body, symbolize_names: true
      end
    end
  end
end
