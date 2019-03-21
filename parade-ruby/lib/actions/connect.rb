require 'uri'

module Paradise
  module Actions
    class Connect < Paradise::Action
      @doc = {
        connect: 'Connect to a server by hostname.'
      }

      def act
        name = query_parts.last

        @context[:host] = parse_host name
        "You connect to the server at #{@context[:host]}"
      end

      private

      def parse_host(host)
        uri = URI.parse(host)
        scheme = uri.scheme

        raise DisallowedScheme unless allowed_schemes.include? scheme

        uri.to_s
      end

      class DisallowedScheme < ParadiseException
      end
    end
  end
end
