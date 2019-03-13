require_relative './vessel'
require 'yaml'

module Paradise
  ##
  # Represents a Paradise world
  class World
    def initialize(data)
      raise 'data must be an array' unless data.is_a? Array

      @world = []

      data.each do |vessel|
        self << vessel
      end
    end

    def self.load(file)
      data = YAML.load(file) # rubocop:disable Security/YAMLLoad
      new(data)
    end

    def dump(file)
      data = []
      @world.each do |vessel|
        data << vessel.dump
      end
      YAML.dump(data, file)
    end

    def self.default
      new [
        # The default user
        { name: 'ghost', parent: 1, owner: 0,
          note: 'Well, well, hello there.' },
        # The paradox
        { name: 'library', parent: 1, owner: 1,
          note: 'Hello @(vessel self "name"), and welcome to the ' \
                '@(cc (vessel parent "name")), the stem to an empty world. ' \
                'Type "@(format "learn")" to get started' },
        # A map with a passive trigger
        { name: 'map', parent: 0, owner: 0, note: 'A basic map',
          triggers: { passive: '@( upcase (vessel parent) )' } }
      ]
    end

    def [](vessel_id)
      @world[vessel_id]
    end

    def validate
      (0...@world.length).each do |id|
        vessel = @world[id]
        vessel.id = id
      end
    end

    def <<(vessel)
      if vessel.is_a? Vessel
        @world << vessel
      elsif vessel.is_a? Hash
        @world << Vessel.from_hash(@world.length, vessel)
      else
        raise 'vessel must be a hash or Paradise::Vessel'
      end
    end

    def children_of(vessel_id)
      children = []
      @world.each do |target|
        children << target if target.parent == vessel_id
      end
      children
    end

    def siblings_of(vessel_id)
      parent_id = @world[vessel_id].parent
      children_of(parent_id) - [@world[vessel_id]]
    end

    def length
      @world.length
    end

    # # rubocop:disable Naming/PredicateName
    def has_a?(vessel_name)
      # rubocop:enable Naming/PredicateName
      @world.each do |v|
        return true if v.full == vessel_name
      end
      false
    end
  end
end
