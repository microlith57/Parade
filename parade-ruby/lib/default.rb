#!/usr/bin/env ruby

require_relative './paradise/world'

module Paradise
  module DefaultWorld
    def default_world
      World.new [
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
  end
end
