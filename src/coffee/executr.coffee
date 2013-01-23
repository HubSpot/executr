$.fn.executr = (opts) ->
  defaults =
    codeSelector: 'code[executable]'

  opts = $.extend {}, defaults, opts

  if this.is(opts.codeSelector)
    # Allow single code blocks to be passed in
    opts.codeSelector = null

  this.on 'click', opts.codeSelector, (e) ->
    $target = $ e.target
    $code = $target.parents(opts.codeSelector)

    ctx = {}
    if opts.setUp?
      CoffeeScript.run opts.setUp, ctx

    CoffeeScript.run $code.text(), ctx

    if opts.tearDown?
      CoffeeScript.run opts.tearDown, ctx

