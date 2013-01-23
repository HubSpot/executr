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
