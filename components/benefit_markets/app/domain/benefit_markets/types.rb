# frozen_string_literal: true

require 'uri'
require 'cgi'
require 'dry-types'

Dry::Types.load_extensions(:maybe)
module BenefitMarkets
  module Types
    include Dry.Types()
    include Dry::Logic

    Uri                 = Types.Constructor(::URI) { |val| ::URI.parse(val) }
    Url                 = Uri

    Email               = Coercible::String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    Emails              = Array.of(Email)
    CallableDateTime    = Types::DateTime.default { DateTime.now }
    Duration            = Types.Constructor(ActiveSupport::Duration) {|val| ActiveSupport::Duration.build(val) }
    PositiveInteger     = Coercible::Integer.constrained(gteq: 0)
    HashOrNil           = Types::Hash | Types::Nil
    DateRange           = Types.Constructor(Types::Range) { |val| val[:min]..val[:max] }
    StringOrNil         = Types::String | Types::Nil

    RequiredSymbol  = Types::Strict::Symbol.constrained(min_size: 2)
    RequiredString  = Types::Strict::String.constrained(min_size: 1)
    StrippedString  = String.constructor(->(val){ String(val).strip })

  end
end