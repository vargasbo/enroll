Feature: Hbx Admin as Paper Application for ivl- User Disagrees to Experian Identity Proofing- User directed to Document Upload page

Background: Hbx Admin navigates into the new consumer application with paper application option and goes forward till DOCUMENT UPLOAD page

  Given Hbx Admin exists
  When Hbx Admin logs on to the Hbx Portal
  And admin has navigated into the NEW CONSUMER APPLICATION
  And the Admin is on the Personal Info page for the family
  And the Admin clicks the Application Type drop down
  And the Admin selects the Paper application option
  And all other mandatory fields on the page have been populated
  When Admin clicks CONTINUE button
  Then the Admin will be navigated to the DOCUMENT UPLOAD page

Scenario: Hbx Admin clicks continue after uploading and verifying an Identity
  Given the Admin will be navigated to the DOCUMENT UPLOAD page
  When the Admin clicks CONTINUE after uploading and verifying an application
  Then the Admin can navigate to the next page and finish the application
