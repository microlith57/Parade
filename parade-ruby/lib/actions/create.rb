require_relative '../paradise/vessel'
require_relative '../paradise/exception'
require 'byebug'

module Paradise
  module Actions
    class Create < Paradise::Action
      def act
        world = @server.world
        owner = world[@context[:user_vessel]]
        proposed_name = @context[:query]
                        .split(' ')[1..-1]

        raise VesselAlreadyPresent if world.has_a? proposed_name.join(' ')

        byebug
        world << Vessel.new(
          world.length,
          owner.parent,
          owner: owner.id,
          data: {
            name: proposed_name[0],
            attr: proposed_name[1..-1]
          }
        )
        puts world
      end

      class VesselAlreadyPresent < ParadiseException
      end
    end
  end
end
