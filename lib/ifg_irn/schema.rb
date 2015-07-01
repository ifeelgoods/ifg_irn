module IfgIrn
  class Schema
    attr_reader :irn_schema

    def initialize(irn)
      @irn_schema = Irn.new(irn)
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
      irn_schema.tokens.each_with_index do |token, i|
        if token == Irn::WILDCARD
          attrs[:data] = data[i..-1]
          raise IfgIrn::IrnInvalidError if Array(attrs[:data]).empty?
        else
          attrs[token.to_sym] = data[i]
          raise IfgIrn::IrnInvalidError unless data[i]
        end
      end
      attrs
    end

    def inspect
      "<Schema  #{irn_schema}>"
    end
  end
end
