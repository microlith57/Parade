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
      full_name = full
      # use 'an' if name starts with a vowel
      return "an #{full_name}" if %w[a e i o u].include? full_name[0]

      # use 'a' otherwise
      "a #{full_name}"
    end

    attr_accessor :id, :parent, :owner, :name, :attr, :program, :note, :triggers
  end
end
