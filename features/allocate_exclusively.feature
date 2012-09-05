Feature: Exclusive allocations

  Development first (allocating development's properties to company).
  
  Exclusivity (from offering company's perspective) means that there's only one receiving company
  for a particular property.

  No hundred records in the DB for property allocations please!
  Instead we have to group properties and allocate those groups instead.

  All properties that are not in an exclusive group are by default in the internal 'default' group.
  
  When a property is added to an exclusive group, it is 'flagged' on all other groups. Properties are
  flagged rather than removed because if the exclusive group is removed, the property should be 'nflagged'.
  
  A flagged property in a group should not appear in any other agent's stock.
  
  When allocating a sub-set of properties to an agent (whether exclusively or non-exclusively), a group 
  should implicitly be created for that allocation, and the user should be asked to name the group.

  When allowing an agent to sell a development, without giving access to a specific group, 
  the agent is internally given access to sell the internal 'default' group.

  Background:
    Given I am signed in as a company admin

  @wip
  Scenario: Exclusively allocating a property
    Given a property "Eureka - 101" that I own exists
    And the development "Eureka" can be sold by "Motion" company
    And the development "Eureka" can be sold by "ASS" company
    When I exclusively allocate that property to "Motion" company
    Then that property should be added to the "Exclusive - Motion" group
    And "ASS" company should not be able to sell that property
    And "Motion" company should be able to sell the "Exclusive - Motion" group

  @wip
  Scenario: Removing an exclusive allocation
    Given a property "Eureka - 101" that I own exists
    And the development "Eureka" can be sold by "Motion" company
    And the development "Eureka" can be sold by "ASS" company
    When I exclusively allocate that property to "Motion" company
    And I remove that exclusive allocation
    Then "Motion" company should be able to sell that property
    And "ASS" company should be able to sell that property


  # Probably not necessary... but let it be for now...
  @wip
  Scenario: Allocating overlapping groups exclusively and non-exclusively
    Given a property "Eureka - 101" exists in "Motion" group
    And a property "Eureka - 102" exists in "Motion" group
    And a property "Eureka - 102" exists in exclusive "Secret" group
    And a property "Eureka - 103" exists in exclusive "Secret" group
    When I give "Motion" group to "Motion" company
    And I give "Secret" group to "Motion" company
    Then "Motion" should be able to sell "Eureka - 101, Eureka - 102, Eureka - 103"

  @wip
  Scenario: Cannot allocate exclusively twice
    Given a property "Eureka - 101" that I own
    Given a property "Eureka - 102" that I own
    And the development "Eureka" can be sold by "Motion" company
    And the development "Eureka" can be sold by "ASS" company
    When I exclusively allocate "Eureka - 101" property to "Motion" company
    Then I should not be able to allocate "Eureka - 101" to any company

  @wip
  Scenario: Allocating a non-exclusive group of properties
    Given a property "Eureka - 101" that I own
    Given a property "Eureka - 102" that I own
    And a company "Motion" exists
    When I create a new group "NRAS" for the "Eureka" development
    And I add "Eureka - 101" property to the "NRAS" group
    And I allocate the "NRAS" group of "Eureka" development to "Motion" company
    Then "Motion" should be able to sell "Eureka - 101" property
    And "Motion" company should not be able to sell "Eureka - 102" property

  @wip
  Scenario: Exclusive allocations within delegations
    Given a property "Eureka - 101" that I own exists
    And a property "Eureka - 102" that I own exists
    And the development "Eureka" can be sold by "Motion" company
    And an exclusive allocation to "Motion" company for "Eureka - 101, Eureka - 102" property exists
    And I log in as "Motion" company admin
    And a company "Other" exists
    And "Other" company can sell "Eureka" development from my company
    When I exclusively allocate "Eureka - 101" to "ASS" company
    Then "ASS" company should be able to sell "Eureka - 101" property
    And "ASS" company should not be able to sell "Eureka - 102" property
    And "Other" company should not be able to sell "Eureka - 101" property
    And "Other" company should be able to sell "Eureka - 102" property

