Feature: Company management
  In order to perform business operations and manage staff
  As a system user
  I want to be able to manage the company in the system


  Scenario: Switching a company
    Given a company "ASS" exists
    And the user "Asaf" is an owner of "ASS" company
    And I sign in as that user
    Given a company "MotionProperty" exists
    And the user "Asaf" is an owner of "MotionProperty" company
    When I go to switch company page
    And choose "MotionProperty"
    When I press "Proceed"
    Then I should see "MotionProperty"
    Given I go to switch company page
    When I choose "ASS"
    When I press "Proceed"
    Then I should see "ASS"



