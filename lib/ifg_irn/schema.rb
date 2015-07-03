module IfgIrn
  class Schema
    REGEXP = /\A\??(\w|-)+(:\??(\w|-)+)+(:\*)?\z/.freeze
    TOKEN_REGEXP = /\A((\w|-)+|\*)\z/.freeze

    def initialize(irn)
      raise ArgumentError, 'bad argument (expected an IRN string)' unless irn.respond_to?(:to_str)
      raise IfgIrn::IrnMalformedError unless REGEXP =~ irn
      @irn_schema = irn
    end

    def tokens
      @irn_schema.split(':')
    end

    def build(irn)
      return build_from_str(irn) if irn.respond_to?(:to_str)
      return build_from_hash(irn) if irn.respond_to?(:to_hash)
      raise ArgumentError, 'bad argument (expected an IRN string or Hash)'
    end

    def validate(irn)
      !! build(irn)
    rescue IfgIrn::IrnError
      false
    end

    def parse!(irn)
      attrs = {}
      data = irn.split(':')
      tokens.each_with_index do |token, i|
        if token == Irn::WILDCARD
          attrs[:data] = data[i..-1]
        elsif token[0] == '?'
          name = token[1..-1].to_sym
          attrs[name] = data[i]
          raise IfgIrn::IrnInvalidError unless data[i]
        else
          name = token.to_sym
          attrs[name] = data[i]
          raise IfgIrn::IrnInvalidError unless data[i] == token
        end
      end
      attrs
    end

    def inspect
      "<Schema  #{@irn_schema}>"
    end

    private

      def build_from_str(irn)
        Irn.new(irn, schema: self)
      end

      def build_from_hash(irn)
        irn_tokens = [ ]
        tokens.each do |token|
          if token == Irn::WILDCARD
            if irn[:data]
              irn_tokens << Array(irn[:data]).join(':')
            end
          elsif token[0] == '?'
            name = token[1..-1].to_sym
            raise IfgIrn::IrnInvalidError unless TOKEN_REGEXP =~ irn[name]
            irn_tokens << irn[name]
          else
            raise IfgIrn::IrnInvalidError unless irn.fetch(token.to_sym, token) == token
            irn_tokens << token
          end
        end
        build_from_str(irn_tokens.join(':'))
      end
  end
end
