require_relative '../paradise/vessel'
require_relative '../paradise/exception'

module Paradise
  module Actions
    class Create < Paradise::Action
      @doc = 'Create a *new vessel* with a given name. You cannot create' \
             ' vessels with the same name as an existing sibling vessel.'

      def act
        proposed_name = split_name query_parts

        if world.has_a? proposed_name.join(' ')
          raise VesselAlreadyPresent,
                'A vessel with that name is already visible.'
        end

        vessel = form_vessel(*proposed_name)
        world << vessel
        "You created +#{vessel.pretty}+"
      end

      class VesselAlreadyPresent < ParadiseException
      end

      private

      def form_vessel(name, attr)
        Vessel.new(
          world.length,
          user.parent,
          owner: user.id,
          data: {
            name: name,
            attr: attr
          }
        )
      end

      DROPPED_PARTS = %w[a an the].freeze

      def split_name(name)
        parts = name.drop_while do |part|
          DROPPED_PARTS.include? part
        end
        [parts.last,
         parts[0...-1].join(' ')]
      end
    end
  end
end
