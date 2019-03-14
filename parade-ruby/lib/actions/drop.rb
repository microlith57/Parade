module Paradise
  module Actions
    class Drop < Paradise::Action
      @doc = 'Move a vessel you have taken beside you.'

      # REVIEW: Should 'drop a generic desk' match only 'desk',
      #         not 'wooden desk'?
      def act
        @vessel_name = query_parts

        drop_vessel = vessel

        drop_vessel.parent = user.parent
        "You drop the +#{drop_vessel.full}+."
      end

      private

      class TooGeneral < ParadiseException
      end

      class NoMatchingVessels < ParadiseException
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
        world.children_of(@context[:user_vessel]).select { |v| v =~ name }
      end
    end
  end
end
