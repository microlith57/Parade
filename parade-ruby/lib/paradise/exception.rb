module Paradise
  ##
  # Base class for all exceptions that should be caught by the server. These
  # should instead be displayed noticably, for example with a red font. They
  # must exit any running +Action+s.
  class ParadiseException < StandardError
    def human_readable
      if self.class.name == message
        self.class.name.split('::').last
      else
        "#{self.class.name.split('::').last}: #{message}"
      end
    end
  end
end
