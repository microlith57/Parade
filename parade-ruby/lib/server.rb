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
      result, world = @world[vessel_id].query(vessel_id, string, self)
      @world = world
      result
    end

    attr_accessor :world
  end
end
