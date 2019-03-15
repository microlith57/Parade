module Paradise
  module Actions
    class Take < Paradise::Action
      @doc = 'Move a visible vessel into your vessel.'

      # REVIEW: Should 'take a generic desk' match only 'desk',
      #         not 'wooden desk'?
      def act
        name = query_parts

        take_vessel = get_vessel name

        take_vessel.parent = @context[:user_vessel]
        "You take the +#{take_vessel.full}+."
      end
    end
  end
end
