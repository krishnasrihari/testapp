describe "SendReplace", ->
  beforeEach ->
    setFixtures """
      <input name='term' value='abc' />
      <button id='source' data-sendreplace-url='/target' data-sendreplace-params='input[name=term]' data-sendreplace-replace='.results' />

      <select id='sel' data-sendreplace-url='/target' data-sendreplace-on='change' data-sendreplace-params='input[name=term]' data-sendreplace-replace='.results' />

      <div class='results'> <div>
    """
    $("[data-sendreplace-url]").sendReplace()




  it "should submit correct data to the correct url on click", ->
    $("#source").click()
    request = mostRecentAjaxRequest()
    expect(request).toBeTruthy()
    expect(request.url).toBe '/target?term=abc'

  it "should uses GET method", ->
    $("#source").click()
    request = mostRecentAjaxRequest()
    expect(request).toBeTruthy()
    expect(request.method).toBe 'GET'

  it "should submit on custom event", ->
    $("#sel").change()
    request = mostRecentAjaxRequest()
    expect(request).toBeTruthy()
    expect(request.url).toBe '/target?term=abc'


  it "should update the target HTML when the result is received", ->
    $("#source").click()
    request = mostRecentAjaxRequest()
    request.response
      status: 200
      contentType: 'text/html'
      responseText: 'the new HTML'
    expect($('.results')).toHaveText 'the new HTML'
