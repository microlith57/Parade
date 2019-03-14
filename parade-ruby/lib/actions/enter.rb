module Paradise
  module Actions
    class Enter < Paradise::Action
      @doc = 'Move into a visible vessel.'

      # TODO: Implement 'enter any vessel', 'enter any desk', etc.
      # REVIEW: Should 'enter a generic desk' match only 'desk',
      #         not 'wooden desk'?
      def act
        sibling_vessels = world.siblings_of @context[:user_vessel]
        eligible_vessels = sibling_vessels.select do |vessel|
          vessel =~ query
        end

        raise TooGeneral if eligible_vessels.length > 1
        raise NoMatchingVessels if eligible_vessels.empty?

        user.parent = eligible_vessels.first.id
        "You enter the +#{eligible_vessels.first.full}+."
      end
    end
  end
end
