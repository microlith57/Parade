#!/usr/bin/env ruby

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
      [action.act, @world]
    rescue ParadiseException => exception
      [exception, @world]
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
      if %w[a e i o u].include? full_name[0]
        return "an #{full_name}"
      else
        return "a #{full_name}"
      end
    end

    attr_accessor :id, :parent, :owner, :name, :attr, :program, :note, :triggers
  end
end
