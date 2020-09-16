Feature: Broker unable to see the Ageoff Exclusion checkbox

 Background: Setup site, employer, and benefit application
    Given a CCA site exists with a benefit market
    Given benefit market catalog exists for enrollment_open initial employer with health benefits
    And there is an employer ABC Widgets
    And initial employer ABC Widgets has enrollment_open benefit application
    And ABC Widgets has census employee, person record, and active coverage for employee Patrick Doe

  Scenario: Broker should not see the Ageoff Exclusion checkbox
    Given that a broker with HBX staff role exists
    And the broker is signed in
    When the broker is on the Family Index of the Admin Dashboard
    # And the user clicks on Families tab
    # And the user clicks on the name of person Patrick Doe from family index_page
    # And the user clicks on the Manage Family button
    # And the user clicks on the Personal tab
