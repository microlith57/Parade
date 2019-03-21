require_relative './vessel'
require 'yaml'

module Paradise
  ##
  # Represents a Paradise world
  class World
    PERMITTED_CLASSES = [Symbol, Vessel].freeze

    def initialize(data)
      raise 'data must be an array' unless data.is_a? Array

      @world = []

      data.each do |vessel|
        self << vessel
      end
    end

    # TODO: Implement version dependent switch between permitted_classes and
    #       whitelist_classes
    def self.load(file)
      text = file.read
      data = YAML.safe_load(text, PERMITTED_CLASSES)
      if data.nil?
        default
      else
        new(data) || default
      end
    end

    def dump(file)
      YAML.dump(@world, file)
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

    def all_vessels
      @world
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
      children_of(parent_id) - [@world[vessel_id], @world[parent_id]]
    end

    def length
      @world.length
    end

    # # rubocop:disable Naming/PredicateName
    def has_a?(vessel_name)
      # rubocop:enable Naming/PredicateName
      !search(vessel_name).empty?
    end

    def search(vessel_name)
      @world.select do |vessel|
        vessel =~ vessel_name
      end
    end
  end
end
