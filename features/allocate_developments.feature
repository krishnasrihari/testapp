@javascript
Feature: Allocating developments to other companies
  In order to allow external companies to sell my stock
  As a company manager
  I want to be able to share the developments

  The sell permission should be chainable (delegatable).
  The manage permission only applies within the owning company.
  For example: when a user is added to the 'managers' group within a
  company, he should not be able to add other users to the managers group
  of that company. Any users that he adds to the managers group of his
  own company, would be able to manage developments that he owns only,
  not development that he can manage (which would include external developments)



  Background:
    Given a registered company with admin user "me@example.com"
    And I sign in as that user
    And a development "Eureka" that I own exists


  Scenario: Allocate to an existing company
    Given a registered company "RayWhite" exists
    When I allocate the "Eureka" development to "RayWhite" company
    Then the company "RayWhite" should have "Eureka" development in stock


  Scenario: Allocate to an existing company when its user belongs to multiple companies
    Given a registered company "BarryPlant" with admin user "slacker" exists
    And a registered company "RayWhite" with admin user "slacker" exists
    When I allocate the "Eureka" development to "RayWhite" company
    Then the company "RayWhite" should have "Eureka" development in stock
    But the company "BarryPlant" should not have "Eureka" development in stock


  Scenario: Allocate to an existing company using the user's email
    Given a registered company "RayWhite" with admin user "ray-admin@example.com" exists
    When I allocate the "Eureka" development to "RayWhite" found by "ray-admin@example.com"
    Then the company "RayWhite" should have "Eureka" development in stock


  @wip
  Scenario: Allocate to a non-existing company (e.g. invite a company)
    When I allocate the "Eureka" development to a new company via user "alien"
    Then the company invitation email should be sent to "alien"
    And a company with invited admin user "alien" should be created
    And that company should have "Eureka" development in stock


  @wip
  Scenario: Allocate to a non-existing company through an existing user
    Given a user "gagarin" exists
    When I allocate the "Eureka" development to a new company via user "gagarin"
    Then the company invitation email should be sent to "gagarin"
    And a company with invited admin user "gagarin" should be created
    And that company should have "Eureka" development in stock



  @wip
  Scenario: Registering a company to receive an allocation
    Given I allocate the "Eureka" development to a new company via user "gagarin"
    And I sign out
    When I open the email of "gagarin" with subject "PropConnect Registration Instructions"
    And follow "Accept" link in the email
    And submit the company registration information with:
      | First name            | Yuri                |
      | Last name             | Gagarin             |
      | Email                 | gagarin@example.com |
      | Password              | 1111                |
      | Password confirmation | 1111                |
      | Company name          | RayWhite            |
    Then the company "RayWhite" with admin user "gagarin" should exist
    And I should be signed in as "gagarin"
    And the company "RayWhite" should have "Eureka" development in stock

