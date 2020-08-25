require 'rails_helper'

describe "insured/family_relationships/index.html.erb" do
  let!(:person) { FactoryBot.create(:person,:with_consumer_role) }
  let!(:person2) { FactoryBot.create(:person) }
  let!(:user) { FactoryBot.create(:user, person: person) }
  let!(:family) do
    family = FactoryBot.create(:family, :with_primary_family_member,person: person)
    FactoryBot.create(:family_member,family: family,person: person2)
    person.person_relationships.create!(family_id: family.id, predecessor_id: person.id, successor_id: person2.id, kind: "spouse")
    person2.person_relationships.create!(family_id: family.id, predecessor_id: person2.id, successor_id: person.id, kind: "spouse")
    person.save!
    person2.save!
    family.save!
    family
  end
  let!(:application) {FactoryBot.create(:application, family: family, assistance_year: 2017,aasm_state: "draft")}

  before :each do
    sign_in user
    assign :person, person
    assign :family, family
    @matrix = family.build_relationship_matrix
    @all_relationships = family.find_all_relationships(@matrix)
    allow(view).to receive(:policy_helper).and_return(double("Policy", updateable?: true))
  end

  it "should have title" do
    render template: "insured/family_relationships/index.html.erb"
    expect(rendered).to have_selector("h1", text: 'Family Relationships')
  end

  it "should render the form partial" do
    expect(render).to render_template(partial: '_form')
  end

  it "should render the individual progress" do
    expect(render).to render_template(partial: '_right_nav')
  end
end
