require 'spec_helper'

describe IrnList do
  describe 'A new irn list' do
    let(:list) { IrnList.new }

    it 'is empty' do
      expect(list).to be_empty
    end
  end

  describe 'An irn list with initial value' do
    let(:list) do
      IrnList.new([
        Irn.new('irn:acme:client:1'),
        Irn.new('irn:acme:client:2')
      ])
    end

    it 'is not empty' do
      expect(list.size).to eq(2)
    end
  end

  describe 'an irn list initial values as string' do
    let(:list) do
      IrnList.new([
        'irn:acme:client:1',
        'irn:acme:client:2'
      ])
    end

    it 'convert string to irn' do
      expect(list.first).to eq(Irn.new('irn:acme:client:1'))
    end
  end

  describe 'an irn list with duplicated value' do
    let(:list) do
      IrnList.new([
        'irn:acme:client:1',
        'irn:acme:client:*',
        'irn:acme:client:1',
        'irn:acme:client:*'
      ])
    end

    it 'ignore duplicated values' do
      expect(list.size).to eq(2)
    end
  end

  describe '#member?' do
    context 'with an empty irn list' do
      let(:list) { IrnList.new }

      it 'does not match' do
        irn = Irn.new('irn:acme:client:1')
        expect(list.member?(irn)).to be(false)
      end
    end

    context 'with a list of irn' do
      let(:list) do
        IrnList.new([
          'irn:acme:client:1',
          'irn:acme:client:2',
          'irn:acme:product:*'
        ])
      end

      it 'match with an irn in the list' do
        irn = Irn.new('irn:acme:client:1')
        expect(list.member?(irn)).to be(true)
      end

      it 'match with an irn matching any wildcard irn' do
        irn = Irn.new('irn:acme:product:1234')
        expect(list.member?(irn)).to be(true)
      end

      it 'does not match when irn is not in the list' do
        irn = Irn.new('irn:acme:client:4')
        expect(list.member?(irn)).to be(false)
      end
    end
  end

  describe '#match' do
    context 'with an empty irn list' do
      let(:list) { IrnList.new }

      it 'return no matching result' do
        irn = Irn.new('irn:acme:client:1')
        expect(list.match(irn)).to be_empty
      end
    end

    context 'with a list of irn' do
      let(:list) do
        IrnList.new([
          'irn:acme:client:1',
          'irn:acme:client:21',
          'irn:acme:client:42',
          'irn:acme:product:1',
          'irn:acme:product:2',
        ])
      end

      it 'return a list of matching result' do
        irn = Irn.new('irn:acme:client:*')
        match_results = list.match(irn)

        expect(match_results.size).to eq(3)
        expect(match_results.map(&:data)).to eq(["1", "21", "42"])
      end
    end
  end

  describe '#restrict' do
    let(:list) do
      IrnList.new([
        'irn:acme:client:1',
        'irn:acme:client:21',
        'irn:acme:client:42',
        'irn:acme:product:*',
        'irn:acme:country:*'
      ])
    end

    let(:list_to_restrict) do
      IrnList.new([
        'irn:acme:client:1',
        'irn:acme:client:9999',
        'irn:acme:product:9999',
        'irn:acme:country:*'
      ])
    end

    let(:restricted) { list.restrict(list_to_restrict) }

    it 'return an irn list' do
      expect(restricted).to respond_to(:restrict)
    end

    it 'return only the irn that match' do
      expect(restricted.size).to eq(3)
    end

    it "include irn members of both list" do
      expect(restricted).to include(Irn.new('irn:acme:client:1'))
      expect(restricted).to include(Irn.new('irn:acme:product:9999'))
      expect(restricted).to include(Irn.new('irn:acme:country:*'))
    end

    it "does not include irn not members of both list" do
      expect(restricted).to_not include(Irn.new('irn:acme:client:9999'))
      expect(restricted).to_not include(Irn.new('irn:acme:product:*'))
    end
  end
end
