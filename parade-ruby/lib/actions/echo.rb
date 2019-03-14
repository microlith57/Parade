module Paradise
  module Actions
    class Echo < Paradise::Action
      @doc = 'Returns the query.'

      def act
        query
      end
    end
  end
end
