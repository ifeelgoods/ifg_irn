require 'set'

class IrnList
  include Enumerable
  extend Forwardable

  def_delegators :@irns, :empty?, :size

  def initialize(irns=[])
    @irns = Set.new(irns.map { |x| Irn.new(x) })
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
    @irns.map { |item| irn.match(item) }.select(&:matched?)
  end

  def restrict(irn_list)
    restriction = irn_list.select { |item| member?(item) }
    IrnList.new(restriction)
  end

  def each
    @irns.each { |x| yield(x) }
  end

  private

    def inspect_irns
      @irns.map(&:inspect).join(', ')
    end
end
