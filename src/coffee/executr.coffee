runners =
  'javascript': (opts, code) ->
      eval code

converters =
  'coffeescript:javascript': (opts, code) ->
    csOptions = $.extend {}, opts.coffeeOptions,
      bare: true

    CoffeeScript.compile code, csOptions

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
    @$runButton.text @opts.buttonText

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
      height: "#{ @$el.height() + 10 }px"
      width: "#{ @$el.width() }px"

    @$editorCont.insertBefore @$el
    @$el.detach()

    mirrorOpts =
      value: @$el.text()
      mode: normalizeType @$el.attr('data-type') ? @opts.defaultType
      
    @editor = CodeMirror @$editorCont[0], $.extend(mirrorOpts, @opts.codeMirrorOptions)
 
  getType: ->
    @editor.getMode().name

  switchType: (type) ->
    type = normalizeType type

    converter = converters["#{ @getType() }:#{ type }"]

    unless converter?
      console.error "Can't convert #{ @getType() } to #{ type }"
      return

    code = converter @opts, @editor.getValue()

    @editor.setOption 'mode', type
    @editor.setValue code
    
  # Do the actual runny bit.
  #
  # Also handles converting the source into a language we know how to run.
  run: (type, opts, code) ->
    runner = runners[type]
    
    # Non-recursivly (max depth == 1) try to convert the source
    # into a language we can run.
    unless runner?
      for key, func of converters
        [from, to] = key.split ':'

        if type is from and runners[to]
          runner = runners[to]
          code = func(opts, code)
          
    if not runner?
      console.error "Couldn't find a way to run #{ type } block"
      return

    runner opts, code

  execute: ->
    code = @getValue()
    codeType = @getType()

    @$el.trigger 'executrBeforeExecute', [code, codeType, @opts]
    if @opts.setUp?
      @opts.setUp(codeType, @opts)

    output = @run codeType, @opts, code

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
    buttonText: "RUN"

  opts = $.extend {}, defaults, opts

  if this.is(opts.codeSelector)
    # Allow single code blocks to be passed in
    opts.codeSelector = null

  this.find(opts.codeSelector).each (i, el) ->
    new Editor({el: el, opts: opts})

