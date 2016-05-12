class Irn
  REGEXP = /\A(\w|-)+(:(\w|-|\+)+)+(:\*)?\z/.freeze
  WILDCARD = '*'.freeze

  attr_reader :attributes

  # Create a new Irn.
  #
  # @param Irn[String] irn to create
  #
  def initialize(irn, schema: nil)
    raise ArgumentError, 'bad argument (expected an IRN string)' unless irn.respond_to?(:to_str)
    raise IfgIrn::IrnMalformedError unless REGEXP =~ irn
    @attributes = schema.parse!(irn) if schema
    @irn = irn.to_str
  end

  def self.regex_registry
    @_regex_registry ||= {}
  end

  def tokens
    @irn.split(':')
  end

  # Return the irn scheme
  #
  def scheme
    tokens.first
  end

  # Return true if the irn has a wildcard at the end.
  def wildcard?
    tokens.last == WILDCARD
  end

  # Return the string representation of the irn.
  def to_s
    @irn
  end

  # Define an implicit string conversion
  #
  def to_str
    @irn
  end

  # Return a human redeable representation of the irn
  # Just like to_s but inside <> to not confuse with a real string
  def inspect
    "<#{self.to_s}>"
  end

  # Return true when the irn is equal to another
  #
  def eql?(other)
    other.to_s == self.to_s
  end

  # Return true when the irn is equal to another
  #
  def ==(other)
    self.eql?(other)
  end

  # Calculate the object hash from its representation
  #
  def hash
    @irn.hash
  end

  # Return true if the irn match another
  #
  # @param other [Irn] the irn to check
  # @param strict [Boolean] Restrict the match to immediate children only
  #
  # @return [Boolean]
  #
  # @note a match relation looks like an ownership. an irn match another
  # if the represent the same resource or the other resource is a sub resource
  # of the first one
  def match?(other, strict: false)
    match(other, strict: strict).matched?
  end

  # Return matching data between a irn and another
  #
  # @param other [Irn] the irn to check
  # @param strict [Boolean] Restrict the match to immediate children only
  #
  # @return [MatchResult]
  def match(other, strict: false)
    match_data = to_regexp(strict).match(other.to_s)
    MatchResult.new(match_data)
  end

  def bind(data)
    raise IfgIrn::IrnCannotBind unless wildcard?
    self.class.new(self.to_s.gsub(WILDCARD, data))
  end

  def gci(other)
    if match?(other)
      other
    elsif other.match?(self)
      self
    end
  end

  private

    def to_regexp(strict)
      if strict
        @_regexp_strict ||= build_regexp('(?<wildcard>\w+)')
      else
        @_regexp ||= build_regexp('(?<wildcard>(\w|:|\*)+)')
      end
    end

    def build_regexp(wildcard_matcher)
      re = @irn.gsub(WILDCARD, wildcard_matcher)
      regex = self.class.regex_registry[re]
      unless regex
        regex = Regexp.new("\\A#{re}\\z")
        self.class.regex_registry[re] = regex.freeze
      end
      regex
    end
end
