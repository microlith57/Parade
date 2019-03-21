require_relative './server'
require 'net/http'
require 'json'

module Paradise
  ##
  # Represents a Paradise client interface
  class Client
    @handlers = {}

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

    def self.add_handler(scheme, handler)
      @handlers[scheme] = handler
    end

    def self.allowed_schemes
      @handlers.keys
    end

    def self.from_host(host)
      conn = handler_for host
      new conn
    end

    class << self
      attr_reader :handlers
    end

    def self.handler_for(host)
      uri = URI.parse host
      if uri.scheme == 'parade'
        return :disconnect if uri.host == 'disconnect'

        if uri.host == 'local'
          uri = URI.parse 'parade-store:///.world.teapot.yaml'
        end
      end
      @handlers[uri.scheme].new uri.to_s
    end

    private

    def process_host(host)
      handler = self.class.handler_for host
      if handler == :disconnect
        disconnect
      else
        connect handler
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
      Client.add_handler 'file', self
      Client.add_handler 'parade-store', self

      def initialize(host = nil, vessel = nil)
        uri = URI.parse host
        if uri.scheme == 'file'
          @world_path = uri.path
        elsif uri.scheme == 'parade-store'
          @world_path = File.join Dir.home, uri.path
        end

        world = if File.exist? @world_path
                  Paradise::World.load File.open(@world_path, 'r')
                else
                  Paradise::World.default
                end
        @serv = Paradise::Server.new world
        super(host, vessel)
      end

      def greet
        res = @serv.greet
        @vessel = res[:vessel_id]
      end

      def disconnect
        File.open(@world_path, 'w') do |f|
          @serv.world.dump f
        end
      end

      def query(string)
        result = @serv.query @vessel, string, Client.allowed_schemes
        @vessel = result[:vessel] if result.key? :vessel
        result
      end
    end

    class HTTPConnection < Connection
      Client.add_handler 'http', self
      Client.add_handler 'https', self # REVIEW

      def greet
        res = get_res '/greet'
        @vessel = res[:vessel]
      end

      def disconnect
        res = get_res '/disconnect'
      end

      def query(string)
        res = get_res '/query',
                      vessel: @vessel,
                      query: string,
                      allowed_schemes: Client.allowed_schemes.join(',')
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
