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
      my_name = self.class.name
      unless instance_of? Paradise::Action
        raise "action #{my_name} must override #act"
      end

      action_name = @context[:query].split(' ').first.capitalize

      action_class = get_action_class action_name

      action = action_class.new @vessel, @context, @server
      action.act
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
      query.join(' ')
    end

    private

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
        raise ParadiseException, 'Two actions have that name.'
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
