module Paradise
  module Actions
    class Disconnect < Paradise::Action
      @doc = 'Disconnect from the server.'

      def act
        @context[:host] = 'parade://disconnect'
        'You disconnect from the server.'
      end
    end
  end
end
