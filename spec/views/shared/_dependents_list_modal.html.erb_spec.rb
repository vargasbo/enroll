require 'rails_helper'

describe "shared/_dependents_list_modal.html.erb" do

  let(:family) { FactoryBot.create(:family, :with_primary_family_member) }
  let(:family_member1) {FactoryBot.create(:family_member, :family => family)}
  let(:family_member2) {FactoryBot.create(:family_member, :family => family)}



  before :each do
    render partial: "shared/dependents_list_modal", locals: { subscriber: [family.primary_applicant], dependents: [family_member1, family_member2]}
  end

  it "shoud have a table with rows" do
    expect(rendered).to have_selector("tr", count: 4)
  end

end
