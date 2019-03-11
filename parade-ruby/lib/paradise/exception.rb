module Paradise
  class ParadiseException < StandardError
    def human_readable
      if self.class.name == message
        message.split('::').last
      else
        message
      end
    end
  end
end
