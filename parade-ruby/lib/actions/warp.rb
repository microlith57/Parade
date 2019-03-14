module Paradise
  module Actions
    class Warp < Paradise::Action
      @doc = {
        warp: 'Move [into](learn to warp inside vessels), or' \
              ' [next to](learn to warp beside vessels), any vessel. You can' \
              ' also warp [randomly](learn to warp randomly)',
        warp_inside_vessels: 'You can warp into any vessel by prefacing the' \
                             ' vessel name with "in", "into", or "inside".',
        warp_beside_vessels: 'You can warp beside any vessel by prefacing the' \
                             ' vessel name with "to" or "beside".',
        warp_randomly: 'You can warp to any matching vessel by placing "any"' \
                       ' before its name, for example "warp to any book". You' \
                       ' can also use "warp to any vessel".'
      }

      # TODO: Implement 'warp the red book into the bookshelf'
      # TODO: Implement 'warp to any vessel'
      # REVIEW: Should 'warp to a generic desk' match only 'desk',
      #         not 'wooden desk'?
      # REVIEW: Should 'warp in' be deprecated in favour of 'warp into'?
      def act
        @vessel_name = query_parts[1..-1]

        warp_vessel = vessel

        if warp_type == :inside
          user.parent = warp_vessel.id
          "You warp inside the +#{warp_vessel.full}+."
        elsif warp_type == :beside
          user.parent = warp_vessel.parent
          "You warp beside the +#{warp_vessel.full}+."
        end
      end

      private

      class TooGeneral < ParadiseException
      end

      class NoMatchingVessels < ParadiseException
      end

      WARP_INSIDE_KEYS = %w[in into inside].freeze
      WARP_BESIDE_KEYS = %w[to beside].freeze

      def warp_type
        string = query_parts.first
        return :inside if WARP_INSIDE_KEYS.include? string
        return :beside if WARP_BESIDE_KEYS.include? string

        raise ParadiseException, '+warp+ must be placed before a keyword.' \
                                 ' Please see +learn to warp+ for more info.'
      end

      def vessel
        if @vessel_name.first == 'any'
          vessel = matching_vessels(@vessel_name[1..-1]).sample
          raise NoMatchingVessels if vessel.nil?

          vessel
        else
          vessels = matching_vessels(@vessel_name)
          raise TooGeneral if vessels.length > 1
          raise NoMatchingVessels if vessels.empty?

          vessels.first
        end
      end

      def matching_vessels(vessel_name)
        name = vessel_name.join ' '
        world.all_vessels.select { |v| v =~ name }
      end
    end
  end
end
