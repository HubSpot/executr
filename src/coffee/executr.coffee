$.fn.executr = (opts) ->
  defaults =
    codeSelector: 'code[executable]'
    outputTo: false
    appendOutput: true

  opts = $.extend {}, defaults, opts

  if this.is(opts.codeSelector)
    # Allow single code blocks to be passed in
    opts.codeSelector = null

  this.on 'click', opts.codeSelector, (e) ->
    $target = $ e.target
    $code = $target.parents(opts.codeSelector)

    if not $code.length and $target.is(opts.codeSelector)
      $code = $target

    code = $code.text()
    
    csOptions = $.extend {}, opts.coffeeOptions

    if opts.outputTo
      code = "window.executrResult = -> #{ code }"

    if opts.setUp?
      CoffeeScript.run opts.setUp

    CoffeeScript.run code, csOptions

    if opts.tearDown?
      CoffeeScript.run opts.tearDown

    if opts.outputTo
      output = window.executrResult

      if opts.appendOutput
        $(opts.outputTo).append $('<div>').text(output)
      else
        $(opts.outputTo).text output

$('body').trigger 'coffeeScriptLoaded'
