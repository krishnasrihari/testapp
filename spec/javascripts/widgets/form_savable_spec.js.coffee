describe "FormSavable", ->

  beforeEach ->
    setFixtures """
      <form data-form-savable='store-prefix'>
        <input name='name' />

        <input id='radio1' type='radio' name='radio' value='1' />
        <input id='radio2' type='radio' name='radio' value='2' />
        <input id='radio3' type='radio' name='radio' value='3' />
      </form>
    """

  initForm = ->
    $("form").formSavable()

  form = -> $("form")
  input = -> $("form input")

  it "should load inputs' state when initialised", ->
    input().val 'stored-value'
    App.Widgets.formSavable.saveForm(form(), 'store-prefix')
    input().val 'form-value'
    initForm()
    expect(input()).toHaveValue 'stored-value'

  it "should trigger change event on modified input", ->
    input().val 'stored-value'
    App.Widgets.formSavable.saveForm(form(), 'store-prefix')
    input().val 'form-value'
    spyOnEvent(input(), 'change')
    App.Widgets.formSavable.restoreForm(form(), 'store-prefix')
    expect('change').toHaveBeenTriggeredOn input()


  it "should persist when an input's value is changed", ->
    input().val('form-value')
    initForm()
    input().val('new-value').trigger('change')
    input().val('not-stored')
    App.Widgets.formSavable.restoreForm(form(), 'store-prefix')
    expect(input().val()).toBe 'new-value'

  it "should select correct radio button", ->
    $("#radio2").prop 'checked', true
    App.Widgets.formSavable.saveForm(form(), 'store-prefix')
    $("#radio1").prop 'checked', true
    App.Widgets.formSavable.restoreForm(form(), 'store-prefix')
    expect( $("#radio2") ).toBeChecked()
