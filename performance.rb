require_relative 'lib/ifg_irn'
require 'benchmark'
# require 'method_profiler'

# profiler1 = MethodProfiler.observe(Irn)
# profiler3 = MethodProfiler.observe(Regexp)

Benchmark.bm(20) do |bm|
  bm.report('match') do
    100000.times.each do
      Irn.new('irn:ifeelgoods:client:*')
          .match?(Irn.new('irn:ifeelgoods:*'))
      Irn.new('irn:ifeelgoods:client:12')
          .match?(Irn.new('irn:ifeelgoods:12'))
    end
  end
end

# puts profiler1.report
# puts profiler3.report
