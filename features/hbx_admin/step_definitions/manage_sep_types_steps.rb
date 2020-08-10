# frozen_string_literal: true

Given(/^that a user with a HBX staff role with (.*) subrole exists$/) do |subrole|
  p_staff = if ['super_admin', 'hbx_tier3'].include?(subrole)
              Permission.create(name: subrole, modify_family: true, modify_employer: true, revert_application: true, list_enrollments: true,
                                send_broker_agency_message: true, approve_broker: true, approve_ga: true,
                                modify_admin_tabs: true, view_admin_tabs: true, can_update_ssn: true, can_access_outstanding_verification_sub_tab: true, can_manage_qles: true)
            else
              Permission.create(name: subrole, modify_family: true, modify_employer: true, revert_application: true, list_enrollments: true,
                                send_broker_agency_message: true, approve_broker: true, approve_ga: true,
                                modify_admin_tabs: true, view_admin_tabs: true, can_update_ssn: true, can_access_outstanding_verification_sub_tab: true, can_manage_qles: false)
            end
  person = people['Hbx Admin']
  hbx_profile = FactoryBot.create :hbx_profile
  user = FactoryBot.create :user, :with_family, :hbx_staff, email: person[:email], password: person[:password], password_confirmation: person[:password]
  FactoryBot.create :hbx_staff_role, person: user.person, hbx_profile: hbx_profile, permission_id: p_staff.id
  FactoryBot.create :hbx_enrollment,family: user.primary_family, household: user.primary_family.active_household
end

And(/the Admin will (.*) the Manage SEP Types under admin dropdown$/) do |action|
  find('.dropdown-toggle', :text => "Admin").click
  if action == 'see'
    find_link('Manage SEP Types').visible? == true
  else
    page.has_css?('Manage SEP Types') == false
  end
end

Given(/^Admin (.*) click Manage SEP Types link$/) do |action|
  if action == 'can'
    page.find('.interaction-click-control-manage-sep-types').click
  else
    page.has_css?('Manage SEP Types') == false
  end
end

Then(/^Admin (.*) navigate to the Manage SEP Types screen$/) do |action|
  if action == 'can'
    expect(page).to have_xpath('//*[@id="Tab:all"]', text: 'All')
    expect(page).to have_xpath('//*[@id="Tab:ivl_qles"]', text: 'Individual')
    expect(page).to have_xpath('//*[@id="Tab:shop_qles"]', text: 'Shop')
    expect(page).to have_xpath('//*[@id="Tab:fehb_qles"]', text: 'Congress')
  else
    expect(page).not_to have_xpath('//*[@id="Tab:all"]', text: 'All')
    expect(page).not_to have_xpath('//*[@id="Tab:ivl_qles"]', text: 'Individual')
    expect(page).not_to have_xpath('//*[@id="Tab:shop_qles"]', text: 'Shop')
    expect(page).not_to have_xpath('//*[@id="Tab:fehb_qles"]', text: 'Congress')
  end
end

Then("Admin should see sorting SEP Types button and create SEP Type button") do
  expect(page).to have_content('Sorting SEP Types')
  step "Admin navigates to Create SEP Type page"
end

When("Admin clicks on List SEP Types link") do
  click_link 'List SEP Types'
end

Then("Admin navigates to SEP Type List page") do
  step "Admin can navigate to the Manage SEP Types screen"
end

def sep_type_start_on
  TimeKeeper.date_of_record.prev_month.at_beginning_of_month
end

def sep_type_end_on
  TimeKeeper.date_of_record.next_year.prev_month.end_of_month
end

def ivl_qualifying_life_events
  {:effective_on_event_date => 1, :effective_on_first_of_month => 2}.map do |event_trait, ordinal_position|
    FactoryBot.create(:qualifying_life_event_kind, event_trait, event_kind_label: "event kind label", market_kind: "individual", post_event_sep_in_days: 90, ordinal_position: ordinal_position, start_on: sep_type_start_on, end_on: sep_type_end_on)
  end
end

def shop_qualifying_life_events
  FactoryBot.create(:qualifying_life_event_kind,
                    title: 'Covid-19',
                    reason: 'covid-19',
                    market_kind: "shop",
                    event_kind_label: "event kind label",
                    post_event_sep_in_days: 1,
                    effective_on_kinds: ["first_of_this_month", "fixed_first_of_next_month"],
                    ordinal_position: 1,
                    qle_event_date_kind: :submitted_at,
                    start_on: sep_type_start_on,
                    end_on: sep_type_end_on)
  FactoryBot.create(:qualifying_life_event_kind, market_kind: "shop", post_event_sep_in_days: 90, ordinal_position: 2, start_on: sep_type_start_on, end_on: sep_type_end_on)
end

def fehb_qualifying_life_events
  {:effective_on_fixed_first_of_next_month => 1, :adoption => 2}.map do |event_trait, ordinal_position|
    FactoryBot.create(:qualifying_life_event_kind, event_trait, market_kind: "fehb", event_kind_label: 'event kind label', post_event_sep_in_days: 90, ordinal_position: ordinal_position, start_on: sep_type_start_on, end_on: sep_type_end_on)
  end
end

And(/^Qualifying life events of all markets are present$/) do
  ivl_qualifying_life_events
  shop_qualifying_life_events
  fehb_qualifying_life_events
end

When("Admin clicks on the Sorting SEP Types button") do
  page.find('.interaction-click-control-sorting-sep-types').click
end

Then("Admin should see three tabs Individual, Shop and Congress markets") do
  expect(page).to have_content('Individual')
  expect(page).to have_content('Shop')
  expect(page).to have_content('Congress')
end

When("Admin clicks on Individual tab") do
  find(:xpath, '//div[2]/div[2]/ul/li[1]/a').click
end

Then("I should see listed Individual market SEP Types") do
  step "Admin should see listed Active individual market SEP Types on datatable"
end

Then(/Admin should see listed Active (.*) market SEP Types on datatable$/) do |market_kind|
  if market_kind == 'individual'
    expect(page).to have_content('Had a baby')
    expect(page).to have_content('Married')
  elsif market_kind == 'shop'
    expect(page).to have_content('Covid-19')
    expect(page).to have_content('Married')
  else
    expect(page).to have_content('Losing other health insurance')
    expect(page).to have_content('Adopted a child')
  end
end

Then(/^\w+ should see listed Individual market SEP Types with ascending positions$/) do
  step "Admin should see listed Active individual market SEP Types on datatable"
  birth_ivl = page.all('div').detect { |div| div[:id] == 'birth_individual'}
  expect(birth_ivl['data-ordinal_position']).to eq '1'
  marraige_ivl = page.all('div').detect { |div| div[:id] == 'marriage_individual'}
  expect(marraige_ivl['data-ordinal_position']).to eq '2'
end

When("Admin sorts Individual SEP Types by drag and drop") do
  l = find("#birth_individual")
  k = find("#marriage_individual")
  k.drag_to(l)
end

And("listed Individual SEP Types ordinal postions should change") do
  step "Admin should see listed Active individual market SEP Types on datatable"
  marraige_ivl = page.all('div').detect { |div| div[:id] == 'marriage_individual'}
  expect(marraige_ivl['data-ordinal_position']).to eq '1'
  birth_ivl = page.all('div').detect { |div| div[:id] == 'birth_individual'}
  expect(birth_ivl['data-ordinal_position']).to eq '2'
end

When("Admin clicks on Shop tab") do
  find(:xpath, '//div[2]/div[2]/ul/li[2]/a').click
end

Then(/^\w+ should see listed Shop market SEP Types with ascending positions$/) do
  step "Admin should see listed Active shop market SEP Types on datatable"
  covid19_shop = page.all('div').detect { |div| div[:id] == 'covid-19_shop'}
  expect(covid19_shop['data-ordinal_position']).to eq '3'
  marraige_shop = page.all('div').detect { |div| div[:id] == 'marriage_shop'}
  expect(marraige_shop['data-ordinal_position']).to eq '4'
end

When("Admin sorts Shop SEP Types by drag and drop") do
  l = find("#covid-19_shop")
  k = find("#marriage_shop")
  k.drag_to(l)
end

Then("listed Shop SEP Types ordinal postions should change") do
  step "Admin should see listed Active shop market SEP Types on datatable"
  marraige_shop = page.all('div').detect { |div| div[:id] == 'marriage_shop'}
  expect(marraige_shop['data-ordinal_position']).to eq '3'
  covid19_shop = page.all('div').detect { |div| div[:id] == 'covid-19_shop'}
  expect(covid19_shop['data-ordinal_position']).to eq '4'
end

When("Admin clicks on Congress tab") do
  find(:xpath, '//div[2]/div[2]/ul/li[3]/a').click
end

Then(/^\w+ should see listed Congress market SEP Types with ascending positions$/) do
  step "Admin should see listed Active fehb market SEP Types on datatable"
  latm_fehb = page.all('div').detect { |div| div[:id] == 'lost_access_to_mec_fehb'}
  expect(latm_fehb['data-ordinal_position']).to eq '5'
  adoption_fehb = page.all('div').detect { |div| div[:id] == 'adoption_fehb'}
  expect(adoption_fehb['data-ordinal_position']).to eq '6'
end

When("Admin sorts Congress SEP Types by drag and drop") do
  l = find("#lost_access_to_mec_fehb")
  k = find("#adoption_fehb")
  k.drag_to(l)
end

Then("listed Congress SEP Types ordinal postions should change") do
  step "Admin should see listed Active fehb market SEP Types on datatable"
  adoption_fehb = page.all('div').detect { |div| div[:id] == 'adoption_fehb'}
  expect(adoption_fehb['data-ordinal_position']).to eq '5'
  latm_fehb = page.all('div').detect { |div| div[:id] == 'lost_access_to_mec_fehb'}
  expect(latm_fehb['data-ordinal_position']).to eq '6'
end

Then(/^Admin should see successful message after sorting$/) do
  expect(page).to have_content('Successfully sorted')
  sleep(2)
end

When("Individual with known qles visits the Insured portal outside of open enrollment") do
  FactoryBot.create(:hbx_profile, :no_open_enrollment_coverage_period)
  BenefitMarkets::Products::ProductRateCache.initialize_rate_cache!
  visit "/"
  click_link 'Consumer/Family Portal'
  screenshot("individual_start")
end

And("Employee signed in") do
  find('.btn-link', :text => 'Sign In Existing Account', wait: 5).click
  sleep 5
  fill_in "user[login]", :with => "patrick.doe@dc.gov"
  fill_in "user[password]", :with => "aA1!aA1!aA1!"
  find('.sign-in-btn').click
end

Then("Employee should land on home page") do
  step "I should land on home page"
end

Given(/(.*) Qualifying life events of (.*) market is present$/) do |state, market_kind|
  qlek = FactoryBot.create(:qualifying_life_event_kind, :effective_on_event_date, market_kind: market_kind, event_kind_label: 'event kind label', post_event_sep_in_days: 90, ordinal_position: 3, aasm_state: state, reason: 'domestic partnership')
  if market_kind == "individual"
    reasons = QualifyingLifeEventKind.by_market_kind(market_kind).non_draft.pluck(:reason).uniq
    Types.const_set('IndividualQleReasons', Types::Coercible::String.enum(*reasons))
  elsif market_kind == 'shop'
    qlek.update_attributes(effective_on_kinds: ['first_of_this_month'])
    reasons = QualifyingLifeEventKind.by_market_kind('shop').non_draft.pluck(:reason).uniq
    Types.const_set('ShopQleReasons', Types::Coercible::String.enum(*reasons))
  else
    qlek.update_attributes(effective_on_kinds: ['fixed_first_of_next_month'])
    reasons = QualifyingLifeEventKind.by_market_kind(market_kind).non_draft.pluck(:reason).uniq
    Types.const_set('FehbQleReasons', Types::Coercible::String.enum(*reasons))
  end
end

When("Admin clicks on the Create SEP Type button") do
  page.find('.interaction-click-control-create-sep-types').click
end

Then("Admin navigates to Create SEP Type page") do
  expect(page).to have_content('Create SEP Type')
end

When("Admin fills Create SEP Type form with start and end dates") do
  sleep 1
  fill_in "Start Date", with: sep_type_start_on.strftime('%m/%d/%Y').to_s
  fill_in "End Date", with: sep_type_end_on.strftime('%m/%d/%Y').to_s
end

When("Admin should see Title field filled with title") do
  expect(find('#title').value.present?).to eq true
end

When("Admin should see Event label field filled with event label") do
  expect(find('#event_kind_label').value.present?).to eq true
end

When("Admin should see Tool Tip field filled with tool tip") do
  expect(find('#tool_tip').value.present?).to eq true
end

When("Admin should see Reason field filled with reason") do
  expect(find('#reason').value.present?).to eq true
end

When(/Admin should see (.*) market radio button selected$/) do |market_kind|
  if market_kind == 'individual'
    expect(find(:xpath, '//input[@value="individual"]').value.present?).to eq true
  elsif market_kind == 'shop'
    expect(find(:xpath, '//input[@value="shop"]').value.present?).to eq true
  else
    expect(find(:xpath, '//input[@value="fehb"]').value.present?).to eq true
  end
end

When("Admin should see Pre Event Sep In Days field filled with days") do
  expect(find('#pre_event_sep_in_days').value.present?).to eq true
end

When("Admin should see Post Event Sep In Days field filled with days") do
  expect(find('#post_event_sep_in_days').value.present?).to eq true
end

When(/Admin should see effective on kinds checked based on (.*)$/) do |market_kind|
  if market_kind == 'individual'
    expect(find("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[effective_on_kinds][]'][value='date_of_event']")).to be_checked
  elsif market_kind == 'shop'
    expect(find("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[effective_on_kinds][]'][value='first_of_this_month']")).to be_checked
  else
    expect(find("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[effective_on_kinds][]'][value='fixed_first_of_next_month']")).to be_checked
  end
end

When("Admin fills Create SEP Type form with start on date greater than end on date") do
  fill_in "Start Date", with: sep_type_end_on.strftime('%m/%d/%Y').to_s
  fill_in "End Date", with: sep_type_start_on.strftime('%m/%d/%Y').to_s
end

And("Admin fills Create SEP Type form with Title") do
  fill_in "Title", with: "Entered into a legal domestic partnership"
end

And("Admin fills Create SEP Type form with Event label") do
  fill_in "Event Label", with: "Date of domestic partnership"
end

And("Admin fills Create SEP Type form with Tool Tip") do
  fill_in "Tool Tip", with: "Enroll or add a family member due to a new domestic partnership"
end

And(/Admin selects (.*) market radio button$/) do |market_kind|
  sleep(2)
  if market_kind == 'individual'
    find(:xpath, '//input[@value="individual"]', :wait => 2).click
  elsif market_kind == 'shop'
    find(:xpath, '//input[@value="shop"]', :wait => 2).click
  else
    find(:xpath, '//input[@value="fehb"]', :wait => 2).click
  end
end

And("Admin clicks reason drop down on Create SEP type form") do
  find(:xpath, '//select[@id="reason"]', :wait => 10).click
end

And("Admin selects expired reason from drop down on Create SEP type form") do
  find("option[value='domestic partnership']").click
end

And(/Admin selects active reason from drop down for (.*) SEP type form$/) do |market_kind|
  sleep(2)
  if market_kind == 'individual'
    find("option[value='birth']").click
  elsif market_kind == 'shop'
    find("option[value='marriage']").click
  else
    find("option[value='adoption']").click
  end
end

And("Admin selects effective on kinds for Create SEP Type") do
  find("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[effective_on_kinds][]'][value='date_of_event']").set(true)
end

And(/Admin (.*) select termination on kinds for (.*) SEP Type$/) do |action, market_kind|
  if action == 'cannot' && market_kind == 'individual'
    expect(page).to have_css("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[termination_on_kinds][]']:disabled")
  else
    find("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[termination_on_kinds][]'][value='end_of_event_month']").set(true)
  end
end


And(/Admin (.*) termination on kinds for (.*) market$/) do |action, _market_kind|
  find("input[type='checkbox'][name='forms_qualifying_life_event_kind_form[termination_on_kinds][]'][value='end_of_event_month']").set(true) if action == 'selected'
end

And("Admin fills Create SEP Type form with Pre Event SEP and Post Event SEP dates") do
  fill_in "Pre Event SEP( In Days )", with: "0"
  fill_in "Post Event SEP( In Days )", with: "30"
end

And("Admin clicks on Create Draft button") do
  page.find_button('Create Draft').click
end

Then("Admin should see SEP Type Created Successfully message") do
  expect(page).to have_content('New SEP Type Created Successfully')
end

When("Admin navigates to SEP Types List page") do
  step "Admin should see sorting SEP Types button and create SEP Type button"
end

When(/Admin clicks (.*) filter on SEP Types datatable$/) do |market_kind|
  divs = page.all('div')
  if market_kind == 'individual'
    ivl_filter = divs.detect { |div| div.text == 'Individual' && div[:id] == 'Tab:ivl_qles' }
    ivl_filter.click
  elsif market_kind == 'shop'
    shop_filter = divs.detect { |div| div.text == 'Shop' && div[:id] == 'Tab:shop_qles' }
    shop_filter.click
  else
    fehb_filter = divs.detect { |div| div.text == 'Congress' && div[:id] == 'Tab:fehb_qles' }
    fehb_filter.click
  end
end

And(/Admin clicks on (.*) filter of (.*) market filter$/) do |state, market_kind|
  if state == 'Draft'
    filter_divs = page.all('div')
    if market_kind == 'individual'
      ivl_draft_filter = filter_divs.detect { |div| div.text == 'Draft' && div[:id] == 'Tab:ivl_qles-ivl_draft_qles' }
      sleep 1
      ivl_draft_filter.click
    elsif market_kind == 'shop'
      shop_draft_filter = filter_divs.detect { |div| div.text == 'Draft' && div[:id] == 'Tab:shop_qles-shop_draft_qles' }
      sleep 1
      shop_draft_filter.click
    else
      fehb_draft_filter = filter_divs.detect { |div| div.text == 'Draft' && div[:id] == 'Tab:fehb_qles-fehb_draft_qles' }
      sleep 1
      fehb_draft_filter.click
    end
  elsif state == 'Active'
    filter_divs = page.all('div')
    if market_kind == 'individual'
      ivl_active_filter = filter_divs.detect { |div| div.text == 'Active' && div[:id] == 'Tab:ivl_qles-ivl_active_qles' }
      sleep 1
      ivl_active_filter.click
    elsif market_kind == 'shop'
      shop_active_filter = filter_divs.detect { |div| div.text == 'Active' && div[:id] == 'Tab:shop_qles-shop_active_qles' }
      sleep 1
      shop_active_filter.click
    else
      fehb_active_filter = filter_divs.detect { |div| div.text == 'Active' && div[:id] == 'Tab:fehb_qles-fehb_active_qles' }
      sleep 1
      fehb_active_filter.click
    end
  elsif state == 'Inactive'
    filter_divs = page.all('div')
    if market_kind == 'individual'
      ivl_active_filter = filter_divs.detect { |div| div.text == 'Inactive' && div[:id] == 'Tab:ivl_qles-ivl_inactive_qles' }
      sleep 1
      ivl_active_filter.click
    elsif market_kind == 'shop'
      shop_active_filter = filter_divs.detect { |div| div.text == 'Inactive' && div[:id] == 'Tab:shop_qles-shop_inactive_qles' }
      sleep 1
      shop_active_filter.click
    else
      fehb_active_filter = filter_divs.detect { |div| div.text == 'Inactive' && div[:id] == 'Tab:fehb_qles-fehb_inactive_qles' }
      sleep 1
      fehb_active_filter.click
    end
    sleep 3
  end
end

Then("Admin should see newly created SEP Type title on Datatable") do
  expect(page).to have_content('Entered into a legal domestic partnership')
end

Then("Admin should see failure reason while creating a new SEP Type") do
  expect(page).to have_content('End on must be after start on date')
end

Then("Admin should see failure reason while publishing a new SEP Type") do
  expect(page).to have_content('Active SEP type exists with same reason')
end

When("Admin clicks on newly created SEP Type") do
  find_link('Entered into a legal domestic partnership').click
end

Then("Admin should navigate to update SEP Type page") do
  sleep 1
  expect(page).to have_content('Update SEP Type')
end

When("Admin changes start and end dates of draft SEP Type") do
  fill_in "Start Date", with: TimeKeeper.date_of_record.at_beginning_of_month.strftime('%m/%d/%Y').to_s
  fill_in "End Date", with: TimeKeeper.date_of_record.next_year.end_of_month.strftime('%m/%d/%Y').to_s
end

When("Admin changes start on date greater than end on date") do
  step "Admin fills Create SEP Type form with start on date greater than end on date"
end

And("Admin clicks on Update SEP Type button") do
  find_button('Update SEP Type').click
end

Then("Admin should see Successfully updated message") do
  expect(page).to have_content('SEP Type Updated Successfully')
end

When("Admin clicks on Publish button") do
  find_button('Publish').click
end

Then("Admin should see Successfully publish message") do
  expect(page).to have_content('SEP Type Published Successfully')
end

Then("Admin should see Expire dropdown button") do
  expect(page).to have_content('Expire')
end

Then(/Admin (.*) see Clone button$/) do |action|
  if action == 'cannot'
    expect(page).not_to have_content('Clone')
  else
    expect(page).to have_content('Clone')
  end
end

When("Admin clicks on Expire button of an Active SEP Type") do
  find_link('Expire').click
end

When("Admin clicks on Clone button of an Active SEP Type") do
  find_link('Clone').click
end

When("Admin changes the end on date of an Active SEP Type to expire") do
  fill_in "end_on", with: TimeKeeper.date_of_record.end_of_month.to_s
end

When("Admin fills end on date earlier than start on date of an Active SEP Type") do
  fill_in "end_on", with: TimeKeeper.date_of_record.prev_year.end_of_month.to_s
end

When("Admin fills end on with past date") do
  fill_in "end_on", with: (TimeKeeper.date_of_record - 2.days).to_s
end

When("Admin fills end on with yesterday date") do
  fill_in "end_on", with: TimeKeeper.date_of_record.yesterday.to_s
end

When("Admin clicks on Expire button") do
  find_button("Expire").click
end

Then("Admin should see a successful message of an Expire") do
  expect(page).to have_content('Expiration Date Set On Sep Type Successfully')
end

Then("Admin should see a Expired successful message") do
  expect(page).to have_content('Sep Type Expired Successfully')
end

Then("Admin should see a failure reason of an Expire") do
  expect(page).to have_content("End on: #{TimeKeeper.date_of_record.prev_year.end_of_month} must be after start on date")
end

Then("Admin should see failure reason for past date of an Expire") do
  expect(page).to have_content("End on: Expiration date must be on or after #{TimeKeeper.date_of_record - 1.day}")
end

Then("Admin should see a failure reason of an Update") do
  expect(page).to have_content("End on: End on must be after start on date")
end