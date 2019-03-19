require_relative './action'
require_relative './exception'

module Paradise
  ##
  # Represents a Paradise Vessel
  # TODO: Add more docs here
  class Vessel
    def initialize(id, parent, owner: -1, data: {})
      @id     = id     # Non-negative integer
      @parent = parent # Non-negative integer
      @owner  = owner  # Non-negative integer or -1

      @name     = data.fetch :name         # String (non-empty)
      @attr     = data.fetch :attr,     '' # String
      @program  = data.fetch :program,  '' # String
      @note     = data.fetch :note,     '' # String (markdown)
      @triggers = data.fetch :triggers, {} # Hash of symbol/trigger pairs
      # TODO: Ensure validity of attributes
    end

    def self.from_hash(id, hash)
      data = hash.reject do |datum|
        %i[id parent owner].include? datum
      end

      new(
        id,
        hash[:parent],
        owner: hash.fetch(:owner, -1),
        data: data
      )
    end

    def dump
      { parent: @parent,
        owner: @owner,
        name: @name,
        attr: @attr,
        program: @program,
        note: @note,
        triggers: @triggers }
    end

    def query(id, string, server)
      context = {
        user_vessel: id,
        query: string
      }
      action = Action.new self, context, server
      result = action.act
      server.world = action.world
      [result, server.world]
    rescue ParadiseException => exception
      [exception, server.world]
    end

    def full
      if attr.nil? || attr.empty?
        name
      else
        "#{attr} #{name}"
      end
    end

    def pretty
      # use 'an' if name starts with a vowel
      return "an #{full}" if %w[a e i o u].include? full[0]

      # use 'a' otherwise
      "a #{full}"
    end

    def as_location
      case vessel_type
      when :program
        "the #{full} program"
      when :location
        "the #{full} location"
      when :vessel
        "the #{full} vessel"
      end
    end

    def suggest_action(user)
      if user.parent == @parent
        if vessel_type == :program
          "use the #{full}"
        else
          "enter the #{full}"
        end
      elsif user.parent == @id
        "drop the #{full}"
      end
      "warp into the #{full}"
    end

    def vessel_type
      return :program  unless @program.empty? && @triggers.fetch('use', nil).nil?
      return :location unless @note.empty?
      return :paradox  if @parent == @id

      :vessel
    end

    def =~(other)
      other_name, other_attr = split_name other

      if other_attr.empty? || attr.empty?
        other_name == name
      else
        other_name == name && other_attr == attr
      end
    end

    attr_accessor :id, :parent, :owner, :name, :attr, :program, :note, :triggers

    private

    # TODO: Move this into a library file
    DROPPED_PARTS = %w[a an the].freeze

    # TODO: Move this into a library file
    def split_name(name)
      name = name.split(' ') if name.is_a? String

      parts = name.drop_while do |part|
        DROPPED_PARTS.include? part
      end
      [parts.last,
       parts[0...-1].join(' ')]
    end
  end
end
