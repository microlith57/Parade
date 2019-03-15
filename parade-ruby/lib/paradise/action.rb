require_relative '../paradise/exception'

module Paradise
  ##
  # The base +Action+ class.
  # All other actions must interit from this and be in the +Paradise::Actions+
  # module. They must also respond to +:act+. Optionally, a +@doc+ variable can
  # be defined for +learn+ documentation.
  class Action
    def initialize(vessel, context, server)
      @vessel  = vessel
      @context = context
      @server  = server
    end

    def act
      unless instance_of? Paradise::Action
        my_name = self.class.name
        raise "action #{my_name} must override #act"
      end

      action = get.new @vessel, @context, @server
      action.act
    end

    def get
      action_name = @context[:query].split(' ').first.capitalize
      get_action_class action_name
    end

    def world
      @server.world
    end

    def user
      world[@context[:user_vessel]]
    end

    def query_parts
      @context[:query].split(' ')[1..-1]
    end

    def query
      query_parts.join(' ')
    end

    def get_vessel(name, type: :visible, allow_any: true)
      vessel_types = {
        visible: lambda { |vname|
          world.siblings_of(@context[:user_vessel]).select { |v| v =~ vname }
        },
        children: lambda { |vname|
          world.children_of(@context[:user_vessel]).select { |v| v =~ vname }
        },
        all_vessels: lambda { |vname|
          world.all_vessels.select { |v| v =~ vname }
        }
      }.freeze

      name = name.split(' ') if name.is_a? String

      match_lambda = vessel_types[type]
      if name.first == 'any' && allow_any
        vessel = match_lambda.call(name[1..-1]).sample
        if vessel.nil?
          raise NoMatchingVessels, 'No vessels match that description.'
        end

        vessel
      else
        vessels = match_lambda.call(name)
        if vessels.length > 1
          raise TooGeneral, "#{vessels.length} vessels match that description."
        end
        if vessels.empty?
          raise NoMatchingVessels, 'No vessels match that description.'
        end

        vessels.first
      end
    end

    class TooGeneral < ParadiseException
    end

    class NoMatchingVessels < ParadiseException
    end

    private

    # TODO: Refactor
    def get_action_class(action_name)
      begin
        require_relative "../actions/#{action_name.downcase}"
      rescue LoadError => e
        raise e unless e.message.start_with? 'cannot load such file'

        raise ActionNotFound, "No such action `#{action_name.downcase}`."
      end

      suitable_classes = Paradise::Actions.constants.select do |const|
        const.to_s.casecmp(action_name).zero? &&
          Paradise::Actions.const_get(const).is_a?(Class)
      end

      if suitable_classes.length > 1
        raise ParadiseException, 'Two or more actions have that name.'
      end

      if suitable_classes.empty?
        raise ParadiseException, 'That action is set up incorrectly.' \
                                 ' Please contact its developer.'
      end

      Paradise::Actions.const_get suitable_classes.first
    end

    class ActionNotFound < ParadiseException
    end

    class << self; attr_reader :doc end
    attr_accessor :vessel, :context, :server
  end
end
