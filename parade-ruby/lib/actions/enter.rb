module Paradise
  module Actions
    class Enter < Paradise::Action
      @doc = 'Move into a visible vessel.'

      # REVIEW: Should 'enter a generic desk' match only 'desk',
      #         not 'wooden desk'?
      def act
        name = query_parts

        enter_vessel = get_vessel name

        user.parent = enter_vessel.id
        "You enter the +#{enter_vessel.full}+."
      end
    end
  end
end
