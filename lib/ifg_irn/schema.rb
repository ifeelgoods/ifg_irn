module IfgIrn
  class Schema
    REGEXP = /\A\??(\w|-)+(:\??(\w|-)+)+(:\*)?\z/.freeze

    def initialize(irn)
      raise ArgumentError, 'bad argument (expected an IRN string)' unless irn.respond_to?(:to_str)
      raise IfgIrn::IrnMalformedError unless REGEXP =~ irn
      @irn_schema = irn
    end

    def tokens
      @irn_schema.split(':')
    end

    def build(irn)
      Irn.new(irn, schema: self)
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
  end
end
