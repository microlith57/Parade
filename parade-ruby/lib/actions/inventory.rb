module Paradise
  module Actions
    class Inventory < Paradise::Action
      @doc = 'List all child vessels.'

      # TODO: Move central list-forming logic into library file
      def act
        children = world.children_of @context[:user_vessel]
        text = ''

        (0..children.length - 1).each do |index|
          vessel = children[index]

          text += if index.zero?
                    "+#{vessel.pretty}+"
                  elsif index < (children.length - 1)
                    ", +#{vessel.pretty}+"
                  elsif children.length <= 2
                    " and +#{vessel.pretty}+"
                  else
                    ", and +#{vessel.pretty}+"
                  end
        end

        return 'You are not carrying anything.' if text.empty?

        "You have #{text}"
      end
    end
  end
end
