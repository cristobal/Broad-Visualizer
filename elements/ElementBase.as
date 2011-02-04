package elements
{
	import flash.display.Sprite;
	import flash.events.Event;

	import core.Visualizer;
	import core.Tools;
	import core.events.TraceLoadEvent;
	import core.events.TimedEvent;
	
	
	public class ElementBase extends Sprite
	{
		/**
		 * Name of the element
		 */
		public static const ELEMENT_TYPE:String = "undefined";
		/**
		 * Type of trace file lines associated to this event
		 */
		public static const TRACE_LINE_TYPE:String = "undefined";
		
		
		/**
		 * Reference to the visualizer
		 */
		protected var visualizer_:Visualizer;
		/**
		 * Canvas where all topology must be displayed
		 */
		private var canvas_:Sprite;
		/**
		 * Whether it is visible in the visualization or not
		 */
		protected var visible_:Boolean = false;

		/**
		 * Constructor of the class
		 * 
		 * @param v Reference to the visualizer
		 * @param c Reference to the canvas where the element will be displayed
		 */
		public function ElementBase(v:Visualizer, c:Sprite = null)
		{
			visualizer_ = v;
			canvas_ = c;
			
			if (canvas_ != null)
			{
				canvas_.addChild(this);
				visible_ = true;
			}
			
			v.addEventListener(Visualizer.TRACE_LINE_FOUND, parseTraceLine);
			v.addEventListener(Visualizer.STEP, update);
		}
		
		
		/**
		 * Tries to free all used memory. Use only when an instance of this
		 * class is not needed anymore.
		 */
		public function cleanUp():void
		{
			visualizer_ = null;
			
			if (canvas_ != null && canvas_.contains(this))
				canvas_.removeChild(this);
			canvas_ = null;
		}
		
		
		/**
		 * Function called when a STEP event is raised. Must be overridden in 
		 * derived classes
		 */
		public function update(e:TimedEvent):void
		{
			throw new Error("update has not been overriden in an element class");
		}
		
		
		/**
		 * Name of the element
		 */
		public override function get name():String { return "undefined"; }
		
		/**
		 * Name of the type of trace file lines associated to this element
		 * This is usually a two characters name
		 */
		public function get lineType():String { return "undefined"; }
		
		
		/**
		 * Whether it is visible in the visualization or not
		 */
		public function get isVisible():Boolean { return visible_; }
		
		
		/**
		 * Called when the visualizer has found a new line in the trace of the
		 * simulation to visualize.
		 */
		public function parseTraceLine(e:TraceLoadEvent):void
		{
			if (e.blockType != lineType)
			{
				return;
			}
			
			// Call to loadNewLine, removing the first parameter (event type)
			loadNewLine(e.traceBlock.slice(1));
		}
		
		
		/**
		 * Toggles the visibility of the element
		 */
		public function toggleVisibility(e:Event):void
		{
			if (canvas_ == null)
				return;
			
			if (visible_ = !canvas_.contains(this))
				canvas_.addChild(this);
			else
				canvas_.removeChild(this);
		}
		
		
		/**
		 * Function that loads a new line from the trace file, usually to create
		 * a new keypoint. 
		 * This function should be overriden in every derived class
		 */
		protected function loadNewLine(params:Array):void
		{
			throw new Error("loadNewLine has not been overriden in an element class");
		}
		
		
		/**
		 * Called when the visualizer has found a new line in the trace of the
		 * simulation to visualize.
		 */
		protected function parseTraceBlock(e:TraceLoadEvent):void
		{
			throw new Error("parseTraceBlock has not been overriden in an element class");
		}
		
	}
}
