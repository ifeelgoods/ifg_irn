require 'spec_helper'

module IfgIrn
  describe Schema do
    let(:schema) { Schema.new('irn:?org:?country:*') }

    describe '#parse!' do
      it 'succeed for valid irn' do
        expect(schema.parse!('irn:acme:france:client:123')).to eq({
          irn: 'irn',
          org: 'acme',
          country: 'france',
          data: ['client', '123']
        })

        expect(schema.parse!('irn:acme:france:client')).to eq({
          irn: 'irn',
          org: 'acme',
          country: 'france',
          data: ['client']
        })
      end

      it 'fail with invalid irn' do
        expect{schema.parse!('irn:acme:france')}.to raise_error(IfgIrn::IrnInvalidError)
        expect{schema.parse!('urn:acme:france:client:123')}.to raise_error(IfgIrn::IrnInvalidError)
      end
    end

    describe '#build' do
      it 'build valid irn object' do
        expect(schema.build('irn:acme:france:client:123')).to eq(Irn.new('irn:acme:france:client:123'))
        expect(schema.build('irn:acme:france:client')).to eq(Irn.new('irn:acme:france:client'))
      end

      it 'fail with invalid irn' do
        expect{schema.build('irn:acme:france')}.to raise_error(IfgIrn::IrnInvalidError)
      end

      it 'fail with malformed irn' do
        expect{schema.build('irn:acme:france:client::123')}.to raise_error(IfgIrn::IrnMalformedError)
      end
    end

    describe '#validate' do
      it 'is true when the irn is valid' do
        expect(schema.validate('irn:acme:france:client:123')).to be(true)
      end

      it 'is false when the irn is invalid' do
        expect(schema.validate('irn:acme:france:client::123')).to be(false)
      end
    end
  end
end
