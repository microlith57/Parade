#!/usr/bin/env ruby

require_relative './paradise/world'
require_relative './default'
require 'byebug'

module Paradise
  ##
  # Represents a Paradise server interface
  class Server
    include DefaultWorld

    def initialize(world = nil)
      @world = world || default_world
    end

    def query(vessel_id, string)
      result, world = @world[vessel_id].query(vessel_id, string, self)
      @world = world
      result
    end

    attr_accessor :world
  end
end
