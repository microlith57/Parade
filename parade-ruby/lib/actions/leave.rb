module Paradise
  module Actions
    class Leave < Paradise::Action
      @doc = 'Exit the parent vessel.'

      # REVIEW: What should happen when a query is given?
      def act
        old_parent = world[user.parent]
        user.parent = old_parent.parent
        "You leave the +#{old_parent.full}+."
      end
    end
  end
end
