describe "FormUpdate", ->
  beforeEach ->
    setFixtures """
      <form action='/post/target' method='POST' data-update-on-change='.update-target'>
        <input name='something' value='abc' />
      </form>

      <div class='update-target'> <div>
    """
    @updater = new App.Widgets.FormUpdate form()[0]

  form  = -> $("form")
  input = -> form().find('input')


  it "should be a jQuery plugin", ->
    expect(form().formUpdate).toBeTruthy()

  it "should POST when anything is changed on the form", ->
    input().trigger("change")
    request = mostRecentAjaxRequest()
    expect(request.url).toBe '/post/target'
    expect(request.params).toMatch /something=abc/

  it "should update the target HTML when the result is received", ->
    input().trigger("change")
    request = mostRecentAjaxRequest()
    request.response
      status: 200
      contentType: 'text/html'
      responseText: 'the new HTML'
    expect($('.update-target')).toHaveText 'the new HTML'

