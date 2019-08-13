# frozen_string_literal: true

module Insured
  module Services
    class ProductService

      def initialize(product)
        @product = ::Insured::Serializers::ProductSerializer.new(product).to_hash
        @product[:sbc_document] = ::Insured::Serializers::SbcDocumentSerializer.new(product.sbc_document).to_hash
      end

      def find
        @product
      end
    end
  end
end
