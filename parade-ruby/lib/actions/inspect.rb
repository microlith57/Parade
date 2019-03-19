module Paradise
  module Actions
    class Inspect < Paradise::Action
      @doc = 'Inspect the data of a visible vessel.'

      def act
        name = query_parts

        inspect_vessel = get_vessel name

        "You are inspecting the +#{inspect_vessel.as_location}+\##{inspect_vessel.id}."
      end
    end
  end
end
