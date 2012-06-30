Feature: Cash Withdrawal
  Scenario: Successful withdrawal from an account in credit
    Given I have deposited $200 in my account
    When I request $20 through atm
    Then $20 should be dispensed