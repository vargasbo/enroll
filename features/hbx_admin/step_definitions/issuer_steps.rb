# frozen_string_literal: true

module IssuerWorld
  def issuers
    site = build(:benefit_sponsors_site, :with_owner_exempt_organization, :dc)
    @issuer_profile = create(:benefit_sponsors_organizations_issuer_profile, organization: site.owner_organization)
    @products = create(:benefit_markets_products_health_products_health_product, issuer_profile_id: issuer_profile.id)
  end
end
World(IssuerWorld)

When(/^Hbx Admin clicks on Issuers tab$/) do
  issuers
  find('.hbx-portal').click
  find('li#issuers').click
end

When(/^Hbx Admin click on a carrier$/) do
  click_on(@issuer_profile.legal_name)
end

Then(/^Hbx Admin should see a list of products$/) do
  expect(page).to have_content @products.name
  expect(page).to have_content @products.hios_id
end