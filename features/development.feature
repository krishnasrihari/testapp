Feature: Development
  In order to show good information
  As a manager of the development
  I want to be able to manage it


  Scenario: Create a development listing (UC9)
    Authorised users can create development listings.
    This is usually a one page profile about the property development
    its name, address, profile image, description and other basic information.

    Given I signed in as a company admin
    When I go to create development page
    And I submit required information about the development "Eureka"
    Then the development "Eureka" should be created with a status of Inactive






  @brittle
  Scenario: Change Development image
    Given a registered company with user "dnagir@example.com" and password "1234"
    And I sign in as that user
    And a development "Eureka" that I can manage exists
    And I go to that development
    When I follow "Change Image"
    And attach the file "spec/fixtures/development.jpg" to "Image" 
    And press "Update Development"
    Then I go to that development
    And follow "Change Image"
    Then I should see image "Development"

