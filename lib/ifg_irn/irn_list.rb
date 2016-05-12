require 'set'
require 'forwardable'

class IrnList
  include Enumerable
  extend Forwardable

  def_delegators :@irns, :empty?, :size

  def initialize(irns=[])
    @irns = Set.new(irns.map { |x| Irn.new(x) })
  end

  def initialize_dup(source)
    super
    @irns = source.instance_variable_get(:@irns).dup
  end

  def <<(irn)
    @irns << Irn.new(irn)
    self
  end

  def inspect
    "#<IrnList: {#{inspect_irns}}>"
  end

  def member?(irn)
    @irns.any? { |item|  item.match?(irn) }
  end

  def match(irn)
    @irns.select { |item| irn.match?(item) }
  end

  def restrict(list)
    restriction = IrnList.new
    list.each do |a|
      self.each do |b|
        if common = a.gci(b)
          restriction << common
        end
      end
    end
    restriction
  end

  alias :intersect :restrict

  def restrict_with(irn_list)
    irn_list.restrict(self)
  end

  def subset?(irn_list)
    assert_valid_type!(irn_list)
    @irns.all? { |irn| irn_list.member?(irn) }
  end

  def superset?(irn_list)
    assert_valid_type!(irn_list)
    irn_list.all? { |irn| member?(irn) }
  end

  def union(irn_list)
    assert_valid_type!(irn_list)
    dup.merge!(irn_list)
  end

  def merge!(irn_list)
    assert_valid_type!(irn_list)
    self.class.new(@irns.merge(irn_list))
  end

  def each
    @irns.each { |x| yield(x) }
  end

  private

    def assert_valid_type!(object)
      raise ArgumentError, 'value must be an IrnList' unless object.is_a?(IrnList)
    end

    def inspect_irns
      @irns.map(&:inspect).join(', ')
    end

end
