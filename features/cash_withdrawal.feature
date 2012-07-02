@wip
Feature: Cash Withdrawal
  Scenario: Successful withdrawal from an account in credit
    Given I have credited $200 in my account
    When I withdraw $20 from ATM
    Then $20 should be dispensed
    And the balance of amount should be $180
    
  Scenario: Unsuccessful withdrawal from an account in lower credit balance
  	Given I have credited $400 in my account
  	When I withdraw $450 from ATM
  	Then $450 should not be dispensed
  	And the balance of amount should be $400