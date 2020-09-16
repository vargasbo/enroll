Feature: As an Admin/CSR I am able to see the Ageoff Exclusion checkbox

  Background: Setup site, employer, and benefit application
    Given a CCA site exists with a benefit market
    Given benefit market catalog exists for enrollment_open initial employer with health benefits
    And there is an employer ABC Widgets
    And initial employer ABC Widgets has enrollment_open benefit application
    And ABC Widgets has census employee, person record, and active coverage for employee Patrick Doe

  Scenario Outline: HBX Staff with <subrole> subroles should <action> the Ageoff Exclusion checkbox
    Given that a user with a HBX staff role with <subrole> subrole exists and is logged in
    When the user clicks Families tab
    And the user navigates to the Families screen 
    And the user selects a Person account
    When the user clicks on the Manage Family button
    # And I should see the individual home page 
    # And the Person has a dependent
    # When the user clicks on the edit button of the dependent
    Then the user will <action> the Ageoff Exclusion checkbox 

    Examples:
      | subrole            | action  |
      | Super Admin        | see     |
      | HBX Tier3          | see     |
      | HBX Staff          | see     |
      | Hbx CSR Supervisor | see     |
      | Hbx CSR Tier1      | see     |
      | Hbx CSR Tier2      | see     |
