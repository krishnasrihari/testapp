Feature: Cash Withdrawal
  Scenario: Successful withdrawal from an account in credit
    Given I have deposited $200 in my account
    When I request $20 through atm
    Then $20 should be dispensed
    And the balance of amound should be $180
    
  Scenario: Unsuccessful withdrawal from an account in lower credit balance
  	Given I have deposited $400 in my account
  	When I request $450 through atm
  	Then $450 should not be dispensed