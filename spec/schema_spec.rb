require 'spec_helper'

module IfgIrn
  describe Schema do
    let(:schema) { Schema.new('irn:org:country:*') }

    describe '#validate!' do
      it 'succeed for valid irn' do
        expect(schema.validate!('irn:acme:france:client:123')).to be(true)
        expect(schema.validate!('irn:acme:france:client')).to be(true)
      end

      it 'fail with invalid irn' do
        expect{schema.validate!('irn:acme:france')}.to raise_error(IfgIrn::IrnInvalidError)
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
  end
end
