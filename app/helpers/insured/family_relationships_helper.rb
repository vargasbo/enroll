# frozen_string_literal: true

module Insured
  module FamilyRelationshipsHelper
    def member_name_by_id(id)
      Person.find(id).full_name
    end
  end
end
