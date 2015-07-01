module IfgIrn
  class Schema
    attr_reader :irn_schema

    def initialize(irn)
      @irn_schema = Irn.new(irn)
    end

    def build(irn)
      Irn.new(irn, schema: self)
    end

    def parse!(irn)
      match_data = regexp_schema.match(irn)
      raise IfgIrn::IrnInvalidError unless match_data
      matched_attributes(match_data)
    end

    def regexp_schema
      @regexp_schema ||= build_regexp_schema
    end

    private

      def build_regexp_schema
        re = "\\A"
        @irn_schema.tokens.each_with_index do |token, index|
          if index == 0
            re << "(?<#{token}>(\\w|-)+)"
          elsif token == Irn::WILDCARD
            re << "(?<data>(:(\\w|-)+)+(:\\*)?)"
          else
            re << ":(?<#{token}>(\\w|-)+)+"
          end
        end
        re << "\\z"
        Regexp.new(re)
      end

      def matched_attributes(match_data)
        attrs = { }
        match_data.names.each do |name|
          if name == 'data'
            attrs[name.to_sym] = match_data[name][1..-1]
          else
            attrs[name.to_sym] = match_data[name]
          end
        end
        attrs
      end
  end
end
