runCoffee = (opts, code) ->
  csOptions = $.extend {}, opts.coffeeOptions

  code = "window.executrResult = do ->\n#{ ("\t#{ line }" for line in code.split('\n')).join('\n') }"

  CoffeeScript.run code, csOptions

  output = window.executrResult
  delete window.executrResult
  
  output

runJS = (opts, code) ->
  eval code

normalizeType = (codeType) ->
  switch codeType.toLowerCase()
    when 'js', 'javascript', 'text/javascript', 'application/javascript'
      return 'javascript'
    when 'cs', 'coffee', 'coffeescript', 'text/coffeescript', 'application/coffeescript'
      return 'coffeescript'
    else
      console.log "Code type #{ codeType } not understood."

class Editor
  constructor: (args) ->
    @el = args.el
    @opts = args.opts

    @$el = $ @el

    do @buildEditor
    do @addRunButton

  getValue: ->
    @editor.getValue()

  addRunButton: ->
    @$runButton = $('<button>')
    @$runButton.addClass 'executr-run-button'
    @$runButton.text 'RUN'

    @$editorCont.append @$runButton

    @$runButton.css
      top: "#{ @$editorCont.height() / 2 - @$runButton.height() / 2 }px"

    if @$editorCont.height() < parseInt(@$runButton.css('font-size'), 10) + 4
      @$runButton.css 'font-size', "#{ @$editorCont.height() - 4 }px"

    @$runButton.click => do @execute

  buildEditor: ->
    @$editorCont = $('<div>')
    @$editorCont.addClass 'executr-code-editor'
    @$editorCont.css
      height: "#{ @$el.height() }px"
      width: "#{ @$el.width() }px"

    @$editorCont.insertBefore @$el
    @$el.detach()

    mirrorOpts =
      value: @$el.text()
      mode: normalizeType @$el.attr('data-type') ? @opts.defaultType
      
    @editor = CodeMirror @$editorCont[0], $.extend(mirrorOpts, @opts.codeMirrorOptions)
 
  execute: ->
    code = @getValue()

    codeType = @editor.getMode().name

    @$el.trigger 'executrBeforeExecute', [code, codeType, @opts]
    if @opts.setUp?
      @opts.setUp(codeType, @opts)

    switch codeType
      when 'javascript'
        output = runJS @opts, code
      when 'coffeescript'
        output = runCoffee @opts, code

    if @opts.tearDown?
      @opts.tearDown(output, codeType, @opts)
    @$el.trigger 'executrAfterExecute', [output, code, codeType, @opts]

    insertOutput @opts, output

     
getCodeElement = (e, opts) ->
  $target = $ e.target
  $code = $target.parents(opts.codeSelector)

  if not $code.length and $target.is(opts.codeSelector)
    $code = $target

  $code

insertOutput = (opts, output) ->
  if opts.outputTo
    if opts.appendOutput
      $(opts.outputTo).append $('<div>').text(output)
    else
      $(opts.outputTo).text output

$.fn.executr = (opts) ->
  defaults =
    codeSelector: 'code[executable]'
    outputTo: false
    appendOutput: true
    defaultType: 'coffee'

  opts = $.extend {}, defaults, opts

  if this.is(opts.codeSelector)
    # Allow single code blocks to be passed in
    opts.codeSelector = null

  this.find(opts.codeSelector).each (i, el) ->
    new Editor({el: el, opts: opts})

