module Paradise
  module Actions
    class Look < Paradise::Action
      @doc = 'List all visible vessels.'

      # TODO: Move central list-forming logic into library file
      def act
        siblings = world.siblings_of @context[:user_vessel]
        text = ''

        (0..siblings.length - 1).each do |index|
          vessel = siblings[index]

          text += if index.zero?
                    "+#{vessel.pretty}+"
                  elsif index < (siblings.length - 1)
                    ", +#{vessel.pretty}+"
                  elsif siblings.length <= 2
                    " and +#{vessel.pretty}+"
                  else
                    ", and +#{vessel.pretty}+"
                  end
        end

        return 'You cannot see anything.' if text.empty?

        "You see #{text}"
      end
    end
  end
end
