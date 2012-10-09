View = require './view'
Camera = require '../models/Camera'
CVImage = require '../models/Image'
Color = require '../models/Color'
template = require './templates/home'

module.exports = class HomeView extends View
  id: 'home-view'
  template: template
  demoOne: null
  demoTwo: null
  demoThree: null
  editors: null
  liveEditor: null
  delay: null
  
  events:
    "click #gotoOverview": "gotoOverview"
    "click #gotoConsole": "gotoConsole"
  
  initialize: =>
    @liveEditor = []
    @editors = []
    @delay = []
      
    $(=>
        @demoOne = $("#demoOne .preview")
        @demoTwo = $("#demoTwo .preview")
        @demoThree = $("#demoThree .preview")
        @highlight()
        @kittyDemo()
        @cameraDemo()
    )
    return
  
  gotoOverview: =>
    $("#gotoConsole").removeClass("pressed")
    $("#console").hide()
    $("#gotoOverview").addClass("pressed")
    $("#guide").show()
  
  gotoConsole: =>
    $("#gotoOverview").removeClass("pressed")
    $("#guide").hide()
    $("#gotoConsole").addClass("pressed")
    $("#console").show()
    @liveEditor.refresh()
    setTimeout(@updatePreview, 300);
  
  updatePreview: =>
    previewFrame = document.getElementById('preview');
    preview =  previewFrame.contentDocument ||  previewFrame.contentWindow.document;
    preview.open();
    preview.write("""
<!doctype html>
<head>
<link rel="stylesheet" href="stylesheets/app.css">
<script src="javascripts/vendor.js"></script>
<script src="javascripts/app.js"></script>
<script>require('initialize');</script>
</head>
<body>

<div id="display"></div>

<script>
  display = $("#display")
                  
""" + @liveEditor.getValue() + """
</script>
</body>
</html>

""")
    preview.close();  
  
  highlight: =>
    @liveEditor = CodeMirror.fromTextArea($("#liveDemo .code form textarea").get(0), {
      lineNumbers: true,
      readOnly: false,
      lineWrapping: false,
      fixedGutter: true,
      onChange: =>
        clearTimeout(@delay);
        @delay = setTimeout(@updatePreview, 300);
    });
    @liveEditor.setOption("theme", "ambiance")
    
    elements = $(".demo .code form textarea")
    for i in elements
      editor = CodeMirror.fromTextArea(i, {
        lineNumbers: true,
        readOnly: true,
        lineWrapping: true
      });
      editor.setOption("theme", "ambiance")
      @editors[_i] = editor
  
  # Displays a picture of a cat, the grey
  # version of it, and the binarized
  # version of it.
  kittyDemo:() =>
    one = $('<div class="cvImage"></div>').appendTo(@demoOne)
    two = $('<div class="cvImage"></div>').appendTo(@demoTwo)
    three = $('<div class="cvImage"></div>').appendTo(@demoThree)
    kitty = $("<img/>").attr("src", "images/kitty.jpg").get(0)
    kitty.onload = =>
      k = new CVImage(kitty)
      k1 = k.grayscale()
      k2 = k1.binarize()
      k.show(one)
      k1.show(two)
      k2.show(three)
    return

  # Displays a camera, 
  cameraDemo: =>
    c = new Camera();
    c.init(=>
      one = $('<div class="cvImage"></div>'); @demoOne.html(one)
      two = $('<div class="cvImage"></div>'); @demoTwo.html(two)
      three = $('<div class="cvImage"></div>'); @demoThree.html(three)
      
      @editors[0].setValue("""
Camera = require '../models/Camera'
container = $("body")
c = new Camera();
c.init =>
  setInterval(=>
    # Scaled Camera Shot
    me = c.getImage()
    me = me.scale(.5)
    me = me.saturate()
    me.show(container)
  , 1000/60)
""")
      
      @editors[1].setValue("""
me = c.getImage()
me = me.scale(.5)
me = me.saturate()
me = me.grayscale()  
""")
      
      @editors[2].setValue("""
me = c.getImage()
me = me.scale(.5)                                                      
me = me.hueDistance(357)
me = me.invert()
me = me.binarize(241)
me.show(three)
""")      
      
      setInterval(=>
        # Scaled Camera Shot
        a = c.getImage()
        a = a.scale(.5)
        a = a.saturate()
        a.show(one)
        
        # Greyscale Camera
        b = a.grayscale()
        b.show(two)            
        
        # Color Distance
        e = a.hueDistance(357)
        e = e.invert()
        e = e.binarize(241)
        e.show(three)
      , 1000/60)
    )
    return
