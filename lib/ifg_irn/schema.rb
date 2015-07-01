module IfgIrn
  class Schema
    attr_reader :irn_schema

    def initialize(irn)
      @irn_schema = Irn.new(irn)
    end

    def build(irn)
      Irn.new(irn, schema: self)
    end

    def validate!(irn)
      match_data = regexp_schema.match(irn)
      raise IfgIrn::IrnInvalidError unless match_data
      return true
    end

    def regexp_schema
      @regexp_schema ||= build_regexp_schema
    end

    private

      def build_regexp_schema
        re = "\\A"
        @irn_schema.tokens.each_with_index do |token, index|
          if index == 0
            re << '(\w|-)+'
          elsif token == Irn::WILDCARD
            re << '(:(\w|-)+)+(:\*)?'
          else
            re << '(:(\w|-)+)+'
          end
        end
        re << "\\z"
        Regexp.new(re)
      end
  end
end
