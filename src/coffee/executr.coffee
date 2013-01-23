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

  this.on 'click', opts.codeSelector, (e) =>
    $code = getCodeElement e, opts
    code = $code.text()

    codeType = $code.attr('data-type') ? $code.attr('type') ? opts.defaultType
    codeType = normalizeType codeType

    this.trigger 'executrBeforeExecute', [code, codeType, opts]
    if opts.setUp?
      opts.setUp(codeType, opts)

    switch codeType
      when 'javascript'
        output = runJS opts, code
      when 'coffeescript'
        output = runCoffee opts, code

    if opts.tearDown?
      opts.tearDown(output, codeType, opts)
    this.trigger 'executrAfterExecute', [output, code, codeType, opts]

    insertOutput opts, output
