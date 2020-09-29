# frozen_string_literal: true

module BenefitMarkets
  module Validators
    module BenefitMarketCatalogs
      class BenefitMarketCatalogContract < ::BenefitMarkets::Validators::ApplicationContract

        params do
          required(:application_interval_kind).filled(:symbol)
          required(:application_period).filled(type?: Range)
          required(:probation_period_kinds).value(:array)
          required(:title).filled(:string)
          optional(:description).filled(:string)
          required(:product_packages).value(:array)
        end
      end
    end
  end
end