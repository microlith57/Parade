module Paradise
  module Actions
    class Learn < Paradise::Action
      @doc = 'View documentation for [actions](learn about actions) and' \
             ' [general knowlege](learn about knowledge).'

      # TODO: Index of all knowledge, actions, etc
      GENERAL_KNOWLEDGE = {
        knowledge: 'A library of general knowledge can be accessed via' \
                   ' +learn about+ followed by a term.',
        actions: 'Actions are commands issued to Paradise. Action' \
                   ' documentation can be accessed via +learn to+ followed by' \
                   ' an action.'
      }.freeze

      def act
        term = query_parts[1..-1].join ' '

        case query_parts.first
        when 'to'
          learn_to term
        when 'about'
          learn_about term
        end
      end

      private

      def learn_to(term)
        context = @context.dup
        context[:query] = term.split(' ').first.downcase
        action = Action.new(
          @vessel, context, @server
        ).get

        doc_from_action action
      end

      def doc_from_action(action)
        doc = if action.doc.is_a? Array
                action.doc[term]
              else
                action.doc
              end

        if doc.respond_to? :call
          doc.call
        else
          doc
        end
      end

      # TODO: Implement @wildcard and @:group
      def learn_about(term)
        unless GENERAL_KNOWLEDGE.include? term.to_sym
          raise TermNotFound, "Term '#{term}' not found."
        end

        learn_about_general_knowledge term.to_sym
      end

      def learn_about_general_knowledge(term)
        knowledge = GENERAL_KNOWLEDGE[term]
        if knowlege.respond_to :call
          knowlege.call
        else
          knowledge
        end
      end

      class TermNotFound < ParadiseException
      end
    end
  end
end
