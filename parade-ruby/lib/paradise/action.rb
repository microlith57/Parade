module Paradise
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

      require_relative "../actions/#{action_name.downcase}"
      action_class = eval "Paradise::Actions::#{action_name}"
      action = action_class.new @vessel, @context, @server
      action.act
    end
  end
end
