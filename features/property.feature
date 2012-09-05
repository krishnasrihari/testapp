Feature: Property details
  As a seller
  I want to see property information
  In order to provide good data to clients...


  Background:
    Given I am signed in



  Scenario: View property as a seller
    Given a development "Eureka" with a property "101" that I can sell exists
    When I go to view property details page
    Then I should see "Eureka - 101" property details


  Scenario: View property as anonymous
    Given a development "Eureka" with a property "101" that I cannot sell exists
    When I go to view property details page
    Then I should not see "Eureka - 101" property details


  Scenario: View property as a property manager
    Given a development "Eureka" with a property "101" that I can manage exists
    When I go to view property details page
    Then I should see "Eureka - 101" property details
  
