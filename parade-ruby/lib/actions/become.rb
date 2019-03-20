module Paradise
  module Actions
    class Become < Paradise::Action
      @doc = 'Become a visible vessel.'

      def act
        name = query_parts

        become_vessel = get_vessel name

        @context[:user_vessel] = become_vessel.id
        "You become the +#{become_vessel.full}+."
      end
    end
  end
end
