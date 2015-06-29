require 'spec_helper'

describe Irn do
  it 'has a string representation' do
    irn = Irn.new('irn:ifeelgoods')
    expect(irn.to_s).to eq('irn:ifeelgoods')
  end

  it 'has a human readable representation' do
    irn = Irn.new('irn:ifeelgoods')
    expect(irn.inspect).to eq("<irn:ifeelgoods>")
  end

  describe '#scheme' do
    it 'is the irn scheme' do
      expect(Irn.new('irn:ifeelgoods').scheme).to eq('irn')
    end
  end

  describe 'validations' do
    example 'valid irn' do
      expect{Irn.new('irn:ifeelgoods')}.to_not raise_error
      expect{Irn.new('irn:ifeelgoods:123')}.to_not raise_error
      expect{Irn.new('irn:ifeelgoods:*')}.to_not raise_error
      expect{Irn.new('irn:ifeelgoods-testing:123')}.to_not raise_error
    end

    example 'invalid irn' do
      expect{Irn.new('')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:ifeelgoods:')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:ifeelgoods::1234')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:ifeelgoods :1234')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:ifeelgoods: 1234')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:*:ifeelgoods')}.to raise_error(IfgIrn::IrnMalformedError)
      expect{Irn.new('irn:*')}.to raise_error(IfgIrn::IrnMalformedError)
    end
  end

  describe 'equality' do
    example 'irn are equal if they have the same representation' do
      expect(
        Irn.new('irn:ifeelgoods')
      ).to eq(
        Irn.new('irn:ifeelgoods')
      )
    end

    example 'irn are not equal if they don\'t the same representation' do
      expect(
        Irn.new('irn:ifeelgoods')
      ).to_not eq(
        Irn.new('irn:acme')
      )
    end
  end

  describe '#match?' do
    example 'two equal irn are matching' do
      expect(
        Irn.new('irn:ifeelgoods')
        .match?(Irn.new('irn:ifeelgoods'))
      ).to be(true)
    end

    example 'two distinct irn are not matching' do
      expect(
        Irn.new('irn:ifeelgoods')
        .match?(Irn.new('irn:ifeelgoods2'))
      ).to be(false)
    end

    example 'a wildcard irn matching an irn' do
      expect(
        Irn.new('irn:ifeelgoods:client:*')
        .match?(Irn.new('irn:ifeelgoods:client:1234'))
      ).to be(true)
    end

    example 'a wildcard irn matching an irn' do
      expect(
        Irn.new('irn:ifeelgoods:*')
        .match?(Irn.new('irn:ifeelgoods:client:1234'))
      ).to be(true)
    end

    example 'a wildcard irn strictly non matching an irn' do
      expect(
        Irn.new('irn:ifeelgoods:*')
        .match?(Irn.new('irn:ifeelgoods:client:1234'), strict: true)
      ).to be(false)
    end

    example 'a wildcard irn strictly matching an irn' do
      expect(
        Irn.new('irn:ifeelgoods:client:*')
        .match?(Irn.new('irn:ifeelgoods:client:1234'), strict: true)
      ).to be(true)
    end

    example 'a non wildcard irn cannot match a wildcard irn' do
      expect(
        Irn.new('irn:ifeelgoods:client:1234')
        .match?(Irn.new('irn:ifeelgoods:client:*'))
      ).to be(false)
    end
  end

  describe '#match' do
    example 'two equal irn are matching' do
      result = Irn.new('irn:ifeelgoods').match(Irn.new('irn:ifeelgoods'))
      expect(result.matched?).to be(true)
      expect(result.data).to be(nil)
    end

    example 'two distinct irn are not matching' do
      result = Irn.new('irn:ifeelgoods').match(Irn.new('irn:ifeelgoods2'))
      expect(result.matched?).to be(false)
      expect(result.data).to be(nil)
    end

    example 'a wildcard irn matching an irn' do
      expect(
        Irn.new('irn:ifeelgoods:client:*')
        .match?(Irn.new('irn:ifeelgoods:client:1234'))
      ).to be(true)
    end

    example 'a wildcard irn matching an irn' do
      result = Irn.new('irn:ifeelgoods:client:*').match(Irn.new('irn:ifeelgoods:client:1234'))
      expect(result.matched?).to be(true)
      expect(result.data).to eq('1234')
    end
  end

  describe '#bind' do
    context 'with a wildcard irn' do
      let(:irn) { Irn.new('irn:ifeelgoods:client:*') }

      it 'bind to a new matching irn' do
        bounded_irn = irn.bind('1234')
        expect(bounded_irn.to_s).to eq('irn:ifeelgoods:client:1234')
      end
    end

    context 'with a non wildcard irn' do
      let(:irn) { Irn.new('irn:ifeelgoods:client:1234') }

      it 'cannot bind' do
        expect{irn.bind('9999')}.to raise_error(IfgIrn::IrnCannotBind)
      end
    end
  end
end
