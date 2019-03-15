module Paradise
  module Actions
    class Drop < Paradise::Action
      @doc = 'Move a vessel you have taken beside you.'

      # REVIEW: Should 'drop a generic desk' match only 'desk',
      #         not 'wooden desk'?
      def act
        name = query_parts

        drop_vessel = get_vessel name, type: :children

        drop_vessel.parent = user.parent
        "You drop the +#{drop_vessel.full}+."
      end
    end
  end
end
