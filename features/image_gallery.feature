@javascript
Feature: Image Gallery
  We want to allow project managers to easily upload
  the images to developments so that those are available for the
  sale agents.
  Sometimes we need to have image gallery on properties too.

  Here's how this should work:
  All images are uploaded to the development and are shown by default on all properties within the development.
  When editing a property, you have the option of managing images for that property,
  where you can select which images are shown for that property.



  Scenario: Upload image to the development
    Given I am signed in
    And a development that I own exists
    When I upload an image to the gallery of that development
    And I change the description of the image to "Highest development in Melbourne"
    And I view that development
    Then I should see the image with the description "Highest development in Melbourne"

  Scenario: Selecting the images for a property
    Given I am signed in
    And a property that I own exists
    When I upload two images to the gallery of that development
    And I choose to show the first image on the property
    When I view that property
    Then I should see the first image from the gallery
    But I should not see the second image from the gallery


  Scenario: Showing the default images on the property
    Given I am signed in
    And a property that I own exists
    And I upload two images to the gallery of that development
    When I view that property
    Then I should see all images from the gallery
