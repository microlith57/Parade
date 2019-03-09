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

world = Paradise::World.new [
  # The default user
  { name: 'ghost', parent: 1, owner: 0,
    note: 'Well, well, hello there.' },
  # The paradox
  { name: 'library', parent: 1, owner: 1,
    note: 'Hello @(vessel self "name"), and welcome to the ' \
          '@(cc (vessel parent "name")), the stem to an empty world. ' \
          'Type "@(format "learn")" to get started' },
  # A bookshelf
  { name: 'bookshelf', parent: 1, owner: 0 },
  # A desk
  { name: 'desk', attr: 'panelled', parent: 1, owner: 0 }
]

server = Paradise::Server.new world: world
queue  = [{ vessel_id: 0, string: 'look' }]

# TODO: Make this an actual queue
queue.each do |query|
  server.query(query[:vessel_id], query[:string])
end
