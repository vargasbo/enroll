# When("the user clicks Families tab") do
#     visit exchanges_hbx_profiles_root_path
#   find(:xpath, "//li[contains(., 'Families')]", :wait => 10).click
#   find('li', :text => 'Families', :class => 'tab-second', :wait => 10).click
# end
  
# When("the user navigates to the Families screen") do
#     expect(page).to have_selector 'h1', text: 'Families'
# end

# When("the user selects a Person account") do
#     find('a', :text => /\APatrick Doe\z/, :wait => 10).click
# end

# When("the user clicks on the Manage Family button") do
#     find('a', :text => /\AManage Family\z/).click
#   end