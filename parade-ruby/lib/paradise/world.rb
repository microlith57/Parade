#!/usr/bin/env ruby

require_relative './vessel'

module Paradise
  ##
  # Represents a Paradise world
  class World
    def initialize(data)
      raise 'data must be an array' unless data.is_a? Array

      @world = []

      data.each do |vessel|
        if vessel.is_a? Vessel
          @world << vessel
        elsif vessel.is_a? Hash
          @world << Vessel.from_hash(@world.length, vessel)
        else
          raise 'vessel must be a hash or Paradise::Vessel'
        end
      end
    end

    def self.load(file)
      data = YAML.safe_load(file)
      new(data)
    end

    def dump(file)
      data = []
      @world.each do |vessel|
        data << vessel.dump
      end
      YAML.dump(data, file)
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
  end
end
