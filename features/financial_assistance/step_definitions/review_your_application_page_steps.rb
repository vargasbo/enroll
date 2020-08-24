# frozen_string_literal: true

Then(/^the user is on the Review Your Application page$/) do
  expect(page).to have_content("Review Your Application")
end

