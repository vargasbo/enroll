And(/^the user will see the Manage Sep Types under admin dropdown$/) do
  find('.dropdown-toggle', :text => "Admin").click
  expect(page).to have_content('Manage Sep Types')
end

When("Admin clicks Manage Sep Types") do
  page.find('.interaction-click-control-manage-sep-types').click
end

Given("the Admin is navigated to the Manage Sep Types screen") do
  expect(page).to have_content('Manage Sep Types')
end

And(/^the Admin has the ability to use the following filters for documents provided: All, Individual, Shop and Congress$/) do
  expect(page).to have_xpath('//*[@id="Tab:all"]', text: 'All')
  expect(page).to have_xpath('//*[@id="Tab:ivl_qles"]', text: 'Individual')
  expect(page).to have_xpath('//*[@id="Tab:shop_qles"]', text: 'Shop')
  expect(page).to have_xpath('//*[@id="Tab:fehb_qles"]', text: 'Congress')
end

def ivl_qualifying_life_events
  {:effective_on_event_date => 1, :effective_on_first_of_month => 2}.map { |event_trait , ordinal_position| FactoryBot.create(:qualifying_life_event_kind, event_trait, market_kind: "individual", post_event_sep_in_days: 90, ordinal_position: ordinal_position)}
end

def shop_qualifying_life_events
  {:effective_on_fixed_first_of_next_month => 1, :adoption => 2}.map { |event_trait , ordinal_position| FactoryBot.create(:qualifying_life_event_kind, event_trait, market_kind: "shop", post_event_sep_in_days: 90, ordinal_position: ordinal_position)}
end

def fehb_qualifying_life_events
  @fehb_qles ||= [FactoryBot.create(:qualifying_life_event_kind, title: 'Covid-19', reason: 'covid-19', market_kind: "fehb", post_event_sep_in_days: 1,  effective_on_kinds: ["first_of_this_month", "fixed_first_of_next_month"], ordinal_position: 1, qle_event_date_kind: :submitted_at),
    FactoryBot.create(:qualifying_life_event_kind, market_kind: "fehb", post_event_sep_in_days: 90, ordinal_position: 2)]
end

Given(/^Qualifying life events of all markets are present$/) do
  ivl_qualifying_life_events
  shop_qualifying_life_events
  fehb_qualifying_life_events
end

When("Admin will click on the Sorting Sep Types button") do
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

Then("Admin should see listed Individual market sep types with ascending ordinal positions") do
  expect(page).to have_content('Had a baby')
  expect(page).to have_content('Married')
  birth_ivl = page.all('div').detect { |div| div[:id] == 'birth_individual'}
  birth_ivl['data-ordinal_position'] == '1'
  marraige_ivl = page.all('div').detect { |div| div[:id] == 'marriage_individual'}
  marraige_ivl['data-ordinal_position'] == '2'
end

When("Admin sorts Individual sep types by drag and drop") do
  l = find("#birth_individual")
  k = find("#marriage_individual")
  k.drag_to(l)
end

And("listed Individual sep types ordrinal postions should change") do
  expect(page).to have_content('Married')
  marraige_ivl = page.all('div').detect { |div| div[:id] == 'marriage_individual'}
  marraige_ivl['data-ordinal_position'] == '1'
  expect(page).to have_content('Had a baby')
  birth_ivl = page.all('div').detect { |div| div[:id] == 'birth_individual'}
  birth_ivl['data-ordinal_position'] == '2'
end

When("Admin clicks on Shop tab") do
  find(:xpath, '//div[2]/div[2]/ul/li[2]/a').click
end

Then("Admin should see listed Shop market sep types with ascending ordinal positions") do
  expect(page).to have_content('Losing other health insurance')
  expect(page).to have_content('Adopted a child')
  birth_ivl = page.all('div').detect { |div| div[:id] == 'lost_access_to_mec_shop'}
  birth_ivl['data-ordinal_position'] == '1'
  marraige_ivl = page.all('div').detect { |div| div[:id] == 'adoption_shop'}
  marraige_ivl['data-ordinal_position'] == '2'
end

When("Admin sorts Shop sep types by drag and drop") do
  l = find("#lost_access_to_mec_shop")
  k = find("#adoption_shop")
  k.drag_to(l)
end

Then("listed Shop sep types ordrinal postions should change") do
  expect(page).to have_content('Adopted a child')
  marraige_ivl = page.all('div').detect { |div| div[:id] == 'adoption_shop'}
  marraige_ivl['data-ordinal_position'] == '1'
  expect(page).to have_content('Losing other health insurance')
  birth_ivl = page.all('div').detect { |div| div[:id] == 'lost_access_to_mec_shop'}
  birth_ivl['data-ordinal_position'] == '2'
end

When("Admin clicks on Congress tab") do
  find(:xpath, '//div[2]/div[2]/ul/li[3]/a').click
end

Then("Admin should see listed Congress market sep types with ascending ordinal positions") do
  expect(page).to have_content('Covid-19')
  expect(page).to have_content('Married')
  birth_shop = page.all('div').detect { |div| div[:id] == 'covid-19_fehb'}
  birth_shop['data-ordinal_position'] == '1'
  marraige_shop = page.all('div').detect { |div| div[:id] == 'marriage_fehb'}
  marraige_shop['data-ordinal_position'] == '2'
end

When("Admin sorts Congress sep types by drag and drop") do
  l = find("#covid-19_fehb")
  k = find("#marriage_fehb")
  k.drag_to(l)
end

Then("listed Congress sep types ordrinal postions should change") do
  expect(page).to have_content('Married')
  marraige_fehb = page.all('div').detect { |div| div[:id] == 'marriage_fehb'}
  marraige_fehb['data-ordinal_position'] == '2'
  expect(page).to have_content('Covid-19')
  birth_fehb = page.all('div').detect { |div| div[:id] == 'covid-19_fehb'}
  birth_fehb['data-ordinal_position'] == '2'
end

Then(/^Admin should see successful message after sorting$/) do
  expect(page).to have_content('Successfully sorted')
  sleep(3)
end