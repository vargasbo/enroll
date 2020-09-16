And("the user clicks on Families tab") do
    find(:xpath, '//a[@class="interaction-click-control-families"]', :wait => 10).click
end

And("the user is navigated to the Families screen") do
    expect(page).to have_selector 'h1', text: 'Families'
    wait_for_ajax
end

And(/^the user clicks on the name of person (.*?) from family index_page$/) do |person_name|
    find('a', :text => person_name).click
end

And("the user clicks on the Manage Family button") do
    find('a.interaction-click-control-manage-family', :wait => 10).click
end
  
And("the user clicks on the Personal tab") do
    find('a.interaction-click-control-personal', :wait => 10).click
end

And("the user clicks on the Family tab") do
    find('a.interaction-click-control-family', :wait => 10).click
end

Then("the Ageoff Exclusion checkbox should be present") do
    expect(page).to have_content("Ageoff Exclusion")
end

Then("the user will see the Ageoff Exclusion checkbox") do
    expect(page).to have_content("Ageoff Exclusion")
end

And("the user clicks on Add Member") do
    find(:xpath, '//a[text()=" Add Member"]', :wait => 10).click
end

When(/^the broker is on the Family Index of the Admin Dashboard$/) do
    visit exchanges_hbx_profiles_path
    find('.interaction-click-control-families').click
end