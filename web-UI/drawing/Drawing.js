dojo.provide("drawing.Drawing");

dojo.require("dojox.gfx");
dojo.require("drawing.util.oo");
dojo.require("drawing.util.common");
dojo.require("drawing.defaults");
dojo.require("drawing.manager.Canvas");
dojo.require("drawing.manager.Undo");
dojo.require("drawing.manager.keys");
dojo.require("drawing.manager.Mouse");
dojo.require("drawing.manager.Stencil");
dojo.require("drawing.manager.Anchors");
dojo.require("drawing.stencil._Base");

dojo.require("drawing.stencil.Line");
dojo.require("drawing.stencil.Rect");
dojo.require("drawing.stencil.Ellipse");
dojo.require("drawing.stencil.Path");
dojo.require("drawing.stencil.Text");
dojo.require("drawing.stencil.Image");
dojo.require("drawing.plugins.drawing.Silverlight");


dojo.require("drawing.tools.TextBlock");
dojo.require("drawing.tools.Rect");
dojo.require("drawing.tools.Ellipse");
dojo.require("drawing.tools.Line");

dojo.require("drawing.annotations.Label");
dojo.require("drawing.annotations.Angle");
dojo.require("drawing.annotations.Arrow");

// not using Widget, just dojo.declare
// however, if dijit is available, this
// is registered as a widget

(function(){
	
	var _plugsInitialized = false;
	
	dojo.declare("drawing.Drawing", [], {
		// summary:
		//	Drawing is a project that sits on top of DojoX GFX and uses SVG and
		//	VML vector graphics to draw and display.
		// description:
		//	Drawing is similar to DojoX Sketch, but is designed to be more versatile
		//	extendable and customizeable.
		//	Drawing currently only initiates from HTML although it's technically not
		//	a Dijit to keep the file size light. But if Dijit is available, Drawing
		//	will register itself with it and can be accessed dijit.byId('myDrawing')
		//
		//The files are laid out as such:
		//	- Drawing
		//		The master class. More than one instance of a Drawing can be placed
		//		on a page at one time (although this has not yet been tested). Plugins
		//		can be added in markup.
		// - Toolbar
		//		Like Drawing, Toolbar is a psudeo Dijit that does not need Dijit. It is
		//		optional. It can be oriented horizontal or vertical by placing one of
		//		those params in the class (at least one is required).  Plugins
		//		can be added in markup. A drawingId is required to point toolbar to 
		//		the drawing.
		//	- defaults
		//		Contains the default styles and dimensions for Stencils. An individual
		//		Stencil can be changed by calling stencil.att({color obj}); To change
		//		all styles, a custom defaults file should be used.
		//	-Stencils
		//		Drawing uses a concept of 'Stencils' to avoid confusion between a
		//		Dojox Shape and a Drawing Shape. The classes in the 'stencils' package
		//		are display only, they are not used for actually drawing (see 'tools').
		//		This package contains _Base from which stencils inherit most of their
		//		methods.(Path and Image are display only and not found in Tools)
		//	- Tools
		//		The Tools package contains Stencils that are attached to mouse events
		//		and can be used for drawing. Items in this package can also be selected
		//		and modified.
		//	- Tools / Custom
		//		Holds tools that do not directly extend Stencil base classes and often
		//		have very custom code.
		//	- Library (not implemented)
		//		The Library package, which is not yet implemented, will be the place to
		//		hold stencils that have very specific data points that result in a picture.
		//		Flag-like-banners, fancy borders, or other complex shapes would go here.
		//	- Annotations
		//		Annotations 'decorate' and attach to other Stencils, such as a 'Label'
		//		that can show text on a stencil, or an 'Angle' that shows while dragging
		//		or modifying a Vector, or an Arrow head that is attached to the beggining
		//		or end of a line.
		//	- Manager
		//		Contains classes that control functionality of a Drawing.
		//	- Plugins
		//		Contains optional classes that are 'plugged into' a Drawing. There are two
		//		types: 'drawing' plugins that modify the canvas, and 'tools' which would
		//		show in the toolbar.
		//	- Util
		//		A collection of common tasks.
		//
		// example:
		//	|	<div dojoType="drawing.Drawing" id="drawing" defaults="myCustom.defaults"
		//	|		plugins="[{'name':'drawing.plugins.drawing.Grid', 'options':{gap:100}}]">   
		//	|   </div>
		//
		//	example:
		//	|	<div dojoType="drawing.Toolbar" drawingId="drawing" class="drawingToolbar vertical">
		//	|		<div tool="drawing.tools.Line" 					selected="false">	Line</div>
		//	|		<div tool="drawing.tools.Rect" 				selected="false">	Rect</div>
		//	|		<div tool="drawing.tools.Ellipse" 			selected="false">	Ellipse</div>
		//	|		<div tool="drawing.tools.TextBlock" 		selected="false">	Statement</div>
		//	|		<div tool="drawing.tools.custom.Equation" 	selected="false">	Equation</div>
		//	|		<div plugin="drawing.plugins.tools.Pan" options="{}">Pan</div>
		//	|		<div plugin="drawing.plugins.tools.Zoom" options="{zoomInc:.1,minZoom:.5,maxZoom:2}">Zoom</div>
		//	|	</div>
		//
		//	NOTES:
		//		Although not Drawing and Toolbar, all other objects are created with a custom
		//		declare. See drawing.util.oo
		//
		// ready: Boolean
		//	Whether or not the canvas has been created and Stencils can be added
		ready:false,
		// width: Number
		//	Width of the canvas
		width:0,
		//
		// height: Number
		//	Height of the canvas
		height:0,
		//
		// defaults : Object
		//	Optional replacements for native defaults.
		// plugins: Object
		//	Key values of plugins that apply to canvas.
		//
		constructor: function(/* Object */props, /* HTMLNode */node){
			// summary:
			//	Drawing is not a Dijit. This is the master method.
			//	NOTE:
			// 		props is always null since this is not a real widget
			//		Will change when Drawing can be created programmatically.
			//
			var def = dojo.attr(node, "defaults");
			if(def){
				drawing.defaults =  dojo.getObject(def);
			}
			this.defaults =  drawing.defaults;
			//this.defaults = window[this.defaults];
			
			this.id = node.id;
			this.util = drawing.util.common;
			this.util.register(this); // So Toolbar can find this Drawing
			this.keys = drawing.manager.keys;
			this.mouse = new drawing.manager.Mouse({util:this.util, keys:this.keys});
			this.tools = {};
			this.stencilTypes = {};
			this.srcRefNode = node; // need this?
			this.domNode = node;
			var str = dojo.attr(node, "plugins");
			if(str){
				this.plugins = eval(str);
			}else{
				this.plugins = [];
			}
			
			this.widgetId = this.id;
			dojo.attr(this.domNode, "widgetId", this.widgetId)
			// If Dijit is available in the page, register with it
			if(dijit && dijit.registry){
				dijit.registry.add(this);
				console.log("using dijit")
			}else{
				// else fake dijit.byId
				// FIXME: This seems pretty hacky.
				dijit.registry = {
					objs:{},
					add:function(obj){
						this.objs[obj.id] = obj;
					}
				};
				dijit.byId = function(id){
					return dijit.registry.objs[id];
				};
				dijit.registry.add(this);
				//this._createCanvas(); why was this here? doesn't make sense...
			}
			this._createCanvas();
			
		},
		
		_createCanvas: function(){
			this.canvas = new drawing.manager.Canvas({
				srcRefNode:this.domNode,
				util:this.util,
				mouse:this.mouse,
				callback: dojo.hitch(this, "onSurfaceReady")
			});
			this.initPlugins();
		},
		
		resize: function(/* Object */box){
			// summary:
			//	Resizes the canvas.
			//	If within a ContentPane this will get called automatically.
			//	Can also be called directly.
			//
			dojo.style(this.domNode, {
				width:box.w+"px",
				height:box.h+"px"
			});
			if(!this.canvas){
				this._createCanvas();		
			}else{
				this.canvas.resize(box.w, box.h);
			}
		},
		
		startup: function(){
			//console.info("drawing startup")
		},
		
		getShapeProps: function(/* Object */data) {
			// summary:
			// 	The common objects that are mixed into
			//	a new Stencil.Mostlhy internal, but could be used.
			//
			return dojo.mixin({
				container:this.canvas.surface.createGroup(),
				util:this.util,
				keys:this.keys,
				mouse:this.mouse
			}, data || {});
		},
		
		addPlugin: function(/* Object */plugin){
			// summary:
			//	Add a toolbar plugin object to plugins array
			//	to be parsed
			this.plugins.push(plugin);
		},
		initPlugins: function(){
			// summary:
			// 	Called from Toolbar after a plugin has been loaded
			// 	The call to this coming from toobar is a bit funky as the timing
			//	of IE for canvas load is different than other browsers
			if(!this.canvas || !this.canvas.surfaceReady){
				var c = dojo.connect(this, "onSurfaceReady", this, function(){
					dojo.disconnect(c);
					this.initPlugins();
				})
				return;
			}
			
			dojo.forEach(this.plugins, function(p, i){
				var props = dojo.mixin({
					util:this.util,
					keys:this.keys,
					mouse:this.mouse,
					drawing:this,
					stencils:this.stencils,
					anchors:this.anchors,
					canvas:this.canvas
				}, p.options || {});
				this.registerTool(p.name, dojo.getObject(p.name));
				this.plugins[i] = new this.tools[p.name](props);
			}, this);
			this.plugins = [];
			_plugsInitialized = true;
			// In IE, because the timing is different we have to get the
			// canvas position after everything has drawn. *sigh*
			this.mouse.setCanvas();
		},
		
		onSurfaceReady: function(){
			// summary:
			//	Event that to which can be connected.
			//	Fired when the canvas is ready and can be drawn to.
			//
			this.ready = true;
			console.info("Surface ready")
			this.mouse.init(this.canvas.domNode);
			this.undo = new drawing.manager.Undo({keys:this.keys});
			this.anchors = new drawing.manager.Anchors({mouse:this.mouse, undo:this.undo, util:this.util});
			this.stencils = new drawing.manager.Stencil({canvas:this.canvas, surface:this.canvas.surface, mouse:this.mouse, undo:this.undo, keys:this.keys, anchors:this.anchors});
			
			if(dojox.gfx.renderer=="silverlight"){
				new drawing.plugins.drawing.Silverlight({util:this.util, mouse:this.mouse, stencils:this.stencils, anchors:this.anchors, canvas:this.canvas});
			}
			dojo.forEach(this.plugins, function(p){
				p.onSurfaceReady && p.onSurfaceReady();	
			});
			
			// register stencils that are not in the tool bar
			this.registerTool("drawing.stencil.Image");
			this.registerTool("drawing.stencil.Path");
			this.registerTool("drawing.stencil.Text");
		},
		
		
		addStencil: function(/* String */type, /* Object */options){
			// summary:
			//	Use this method to programmatically add Stencils that display on
			//	the canvas.
			//	FIXME: Currently only supports Stencils that have been registered,
			//		which is items in the toolbar, and the additional Stencils at the
			//		end of onSurfaceReady. This covers all Stencils, but you can't
			//		use 'display only' Stencils for Line, Rect, and Ellipse.
			//	arguments:
			//		type: String
			//			The final name of the tool, lower case: 'image', 'line', 'textBlock'
			//	options:
			//		type: Object
			//			The parameters used to draw the object. See stencil._Base and each
			//			tool for specific parameters of teh data or points objects.
			//
			if(!this.ready){
				var c = dojo.connect(this, "onSurfaceReady", this, function(){
					dojo.disconnect(c);
					this.addStencil(type, options);
				})
				return false;
			}
			if(options && !options.data){
				options = {data:options}
			}
			var s = this.stencils.register( new this.stencilTypes[type](this.getShapeProps(options)));
			// need this or not?
			//s.connect(s, "destroy", this, "onDeleteStencil");
			this.currentStencil && this.currentStencil.moveToFront();
			return s;
		},
		
		removeStencil: function(/* Object */stencil){
			// summary:
			//	Use this method to programmatically remove Stencils from the canvas.
			// arguments:
			//	Stencil: Object
			//		The Stencil to be removed
			//
			this.stencils.unregister(stencil);
			stencil.destroy();
		},
		
		toSelected: function(/*String*/func /*[args, ...]*/){
			// summary:
			//	Call a function within all selected Stencils
			//	like attr()
			// example:
			//	myDrawing.toSelected('attr', {x:10})
			//
			this.stencils.toSelected.apply(this.stencils, arguments);
		},
		
		exporter: function(){
			console.log("this.stencils", this.stencils)
			return this.stencils.exporter();
		},
		
		changeDefaults: function(/*Object*/newStyle){
			// summary:
			//	Change the defaults so that all Stencils from this
			// 	point on will use the newly changed style.
			// arguments:
			//	newStyle: Object
			//		An object that represents one of the objects in
			//		drawing.style that will be mixed in. Not all
			//		properties are necessary. Only one object may
			//		be changed at a time. Non-objects like angleSnap
			//		cannot be changed in this manner.
			// example:
			//	|	myDrawing.changeDefaults({
			//	|		norm:{
			//	|			fill:"#0000ff",
			//	|			width:5,
			//	|			color:"#ffff00"
			//	|		}
			//	|	});
			//
			for(var nm in newStyle){
				for(var n in newStyle[nm]){
					console.log("  copy", nm, n, " to: ", newStyle[nm][n])
					this.defaults[nm][n] = newStyle[nm][n];
				}
			}
			this.unSetTool();
			this.setTool(this.currentType);
		},
		
		onRenderStencil: function(/* Object */stencil){
			// summary:
			//	Event that fires when a stencil is drawn. Does not fire from
			//	'addStencil'.
			//console.info("--------------------------------------drawing.onRenderStencil:", stencil.id);
			this.stencils.register(stencil);
			this.unSetTool();
			this.setTool(this.currentType);
		},
		
		onDeleteStencil: function(/* Object */stencil){
			// summary:
			//	Event fired from a stencil that has destroyed itself
			// 	will also be called when it is removed by "removeStencil"
			// 	or stencils.onDelete. 
			//
			this.stencils.unregister(stencil);
		},
		
		registerTool: function(/* String */type){
			// summary:
			// Registers a tool that can be accessed. Internal.
			var constr = dojo.getObject(type);
			this.tools[type] = constr;
			var abbr = type.substring(type.lastIndexOf(".")+1).charAt(0).toLowerCase()
				+ type.substring(type.lastIndexOf(".")+2);
			this.stencilTypes[abbr] = constr;
		},
		
		setTool: function(/* String */type){
			// summary:
			//	Sets up a new class to be used to draw. Called from Toolbar,
			//	and this class... after a tool is used a new one of the same
			//	type is initialized. Could be called externally.
			//
			if(!this.canvas || !this.canvas.surface){
				var c = dojo.connect(this, "onSurfaceReady", this, function(){
					dojo.disconnect(c);
					this.setTool(type);
				});
				return;
			}
			if(this.currentStencil){
				this.unSetTool();
			}
			this.currentType = type;
			try{
				console.log("new tool ", this.currentType)
				this.currentStencil = new this.tools[this.currentType]({container:this.canvas.surface.createGroup(), util:this.util, mouse:this.mouse, keys:this.keys});
				console.log("new tool is:", this.currentStencil.id, this.currentStencil);
				this.currentStencil.connect(this.currentStencil, "onRender", this, "onRenderStencil");
				this.currentStencil.connect(this.currentStencil, "destroy", this, "onDeleteStencil");
			}catch(e){
				console.error("Drawing.setTool Error:", e);
				console.error(this.currentType + " is not a constructor: ", this.tools[this.currentType]);
				//console.trace();
			}
		},
		
		unSetTool: function(){
			// summary:
			//	Destroys current tool
			if(!this.currentStencil.created){
				this.currentStencil.destroy();	
			}
			
		}
	});
	
})();