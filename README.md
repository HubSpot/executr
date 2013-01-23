executr
=======

Let your users execute the CoffeeScript in your documentation

Including
--------

````html
<!-- You should already have jQuery included -->

<script type="text/javascript" src="http://github.com/jashkenas/coffee-script/raw/master/extras/coffee-script.js"></script>
<script type="text/coffeescript" src="src/coffee/executr.coffee"></script>

<link rel="stylesheet" type="text/css" media="screen" href="src/css/executr.css">
````

Usage
-----

The code blocks you wish to be executable should be wrapped in `<code executable></code>`.

Run `$.executr` on the container of multiple code elements, the body, or a single code block.

````html
<code executable>
$ ->
  alert "Testing!"
</code>
````

````javascript
$(function(){
  $('body').executr();
});
````

Example
------

See our messenger documentation for an example: http://hubspot.github.com/messenger/

Other Options
-------

$.executr can be passed the following options

````coffeescript
{
    codeSelector: 'code[executable]' # The jQuery selector items to be bound must match
    outputTo: 'div.output' # An element which should receive the output.  The output will also be available in window.executrOutput.
    appendOutput: true # Whether output should replace the contents of outputTo, or append to it
    coffeeOptions: {} # Extra options for the CoffeeScript compiler
}
````
