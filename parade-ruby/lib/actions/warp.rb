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
        name = query_parts[1..-1]

        warp_vessel = get_vessel name, type: :all_vessels

        if warp_type == :inside
          user.parent = warp_vessel.id
          "You warp inside the +#{warp_vessel.full}+."
        elsif warp_type == :beside
          user.parent = warp_vessel.parent
          "You warp beside the +#{warp_vessel.full}+."
        end
      end
    end
  end
end
