
beforeEach(function() {
  clearAjaxRequests();
  // jasmine-ajax mock
  jasmine.Ajax.useMock();

  // confirm all dialogs
  spyOn(window, 'confirm').andReturn(true)
});

afterEach(function() {
  // Spies are not yet cleared here
});
