module Paradise
  module Actions
    class Warp < Paradise::Action
      @doc = 'Move into, or next to, any vessel.'

      # TODO: Implement 'warp to', 'warp into'
      # TODO: Implement 'warp to any vessel', 'warp to any desk', etc.
      # REVIEW: Should 'warp to a generic desk' match only 'desk',
      #         not 'wooden desk'?
      # REVIEW: Should 'warp in' be deprecated in favour of 'warp into'?
      def act
        if warp_type == :inside
          user.parent = eligible_vessels.first.id
          "You warp inside the +#{eligible_vessels.first.full}+."
        elsif warp_type == :beside
          user.parent = eligible_vessels.first.parent
          "You warp beside the +#{eligible_vessels.first.full}+."
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

      def eligible_vessels
        name = query_parts[1..-1].join ' '
        vessels = world.all_vessels
        eligible_vessels = vessels.select do |vessel|
          vessel =~ name
        end
        raise TooGeneral if eligible_vessels.length > 1
        raise NoMatchingVessels if eligible_vessels.empty?

        eligible_vessels
      end
    end
  end
end
