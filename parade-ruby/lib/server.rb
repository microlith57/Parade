require_relative './paradise/world'
require 'byebug'

module Paradise
  ##
  # Represents a Paradise server interface
  class Server
    def initialize(world = nil)
      @world = world || World.default
    end

    def query(vessel_id, string)
      string.downcase!
      string.gsub!(/\s+/, ' ') # compress whitespace to single space
      string.strip!
      result, world = @world[vessel_id].query(vessel_id, string, self)
      @world = world
      result
    end

    # TODO: Implement config and world loading
    def greet
      { vessel_id: 0 }
    end

    def disconnect
      # TODO: implement
    end

    attr_accessor :world
  end
end
