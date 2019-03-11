module Paradise
  module Actions
    class Look < Paradise::Action
      @doc = 'List all visible vessels.'

      def act
        siblings = world.siblings_of @context[:user_vessel]
        text = ''

        (0..siblings.length-1).each do |index|
          vessel = siblings[index]

          if index == 0
            text += "+#{vessel.pretty}+"
          elsif index < (siblings.length - 1)
            text += ", +#{vessel.pretty}+"
          elsif siblings.length <= 2
            text += " and +#{vessel.pretty}+"
          else
            text += ", and +#{vessel.pretty}+"
          end
        end

        "You see #{text}"
      end
    end
  end
end
