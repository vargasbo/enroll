# frozen_string_literal: true

Rails.application.routes.draw do
  mount FinancialAssistance::Engine => "/financial_assistance"
end
