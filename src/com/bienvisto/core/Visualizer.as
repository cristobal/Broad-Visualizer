package com.bienvisto.core
{

	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.elements.ElementBase;
	import com.bienvisto.elements.NodeManager;
	import com.bienvisto.elements.SequencesManager;
	import com.bienvisto.elements.buffer.Buffer;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.roles.Roles;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.sequences.SequencesRecv;
	import com.bienvisto.elements.sequences.SequencesSent;
	import com.bienvisto.elements.topology.Topology;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.util.Tools;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
	
	
	public class Visualizer extends UIComponent
	{
		/**
		 * Name of the event dispatched when the visualizer starts loading
		 * loading something. The user interface can listen to this event and
		 * display a progress bar indicating that something is loading
		 */
		public static const LOAD_START:String = "loadStart";
		/**
		 * Name of the event dispatched when the visualizer makes some progress
		 * loading something.
		 */
		public static const LOAD_PROGRESS:String = "loadProgress";
		/**
		 * Name of the event dispatched when the visualizer finishes loading
		 * something
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
		/**
		 * Name of the event dispatched when a new block is read from the trace
		 * file
		 */
		public static const TRACE_LINE_FOUND:String = "traceLineFound";
		/**
		 * Name of the event when there is a "step" in time in the visualization
		 */
		public static const STEP:String = "step";
		/**
		 * Name of the event dispatched when the visualizer reaches the end or
		 * the beginning of the simulation
		 */
		public static const FINISHED:String = "finished";
		/**
		 * Name of the event raised when a node is clicked
		 */
		public static const NODE_CLICKED:String = "nodeClicked";

		/**
		 * Static reference to the last instance of this class. Singleton is not
		 * enforced, but there should not be more than one object of this class
		 */
		public static var instance:Visualizer;


		/**
		 * Array of strings containing the full trace file
		 */
		protected var trace_:Array;
		/**
		 * Timer used during the asynchronous load of the trace file
		 */
		protected var decodingTimer_:Timer;
		/**
		 * Time when the load of the trace started. This is used to measure how
		 * long it takes to load the trace file
		 */
		protected var decodingStart_:uint;
		/**
		 * Size, in bytes, of the trace file. Used to display progress while
		 * loading the trace file
		 */
		protected var traceBytesTotal_:Number;
		/**
		 * Size, in lines, of the trace file. Used to display progress while
		 * loading the trace file
		 */
		protected var traceLinesTotal_:Number;
		/**
		 * Amount of lines loaded
		 */
		protected var traceLinesLoaded_:Number;


		/**
		 * Whether the visualizer is ready to start visualizing or not
		 *
		 * @default false
		 */
		protected var ready_:Boolean = false;
		/**
		 * Top layer of the canvas where all elements will be displayed. This
		 * canvas is used to draw the nodes
		 */
		protected var canvasTopLayer_:Sprite;
		/**
		 * Bottom layer of the canvas where all elements will be displayed.
		 */
		protected var canvasBottomLayer_:Sprite;
		/**
		 * Zoom of the visualization. 1 = 100% zoom
		 */
		protected var zoom_:Number = 1.0;
		/**
		 * X Coordinate of the point to be presented in the center of the screen
		 */
		protected var targetX_:int = 250;
		/**
		 * X Coordinate of the point to be presented in the center of the screen
		 */
		protected var targetY_:int = 250;
		/**
		 * Value returned by flash.utils.getTimer() when the update function was
		 * last called
		 */
		protected var lastUpdate_:uint = 0;
		/**
		 * Milliseconds elapsed since the beginning of the simulation. This is
		 * the value that controls the instant of the simulation which is 
		 * visualized
		 */
		protected var simulationTime_:int = 0;
		/**
		 * Length of the simulation in milliseconds
		 */
		protected var simulationLength_:uint = 1;

		/**
		 * Contains all registered variables. The stats window will provide the
		 * option to represent any of these variables
		 */
		protected var variables_:Vector.<VariableBase>;
		
		/**
		 * @private
		 */ 
		private var _roles:Roles;
		
		/**
		 * @readonly roles
		 */ 
		public function get roles():Roles
		{	
			return _roles;
		}
		
		/**
		 * @private
		 */ 
		private var _nodeManager:NodeManager;
		
		/**
		 * @readonly nodeManager
		 */ 
		public function get nodeManager():NodeManager
		{
			return _nodeManager;
		}
		
		/**
		 * @private
		 */ 
		private var _sequencesManager:SequencesManager;
		
		/**
		 * @readonly sequencesManager
		 */ 
		public function get sequencesManager():SequencesManager
		{
			return _sequencesManager;
		}
		
		
		// ELEMENTS:
		/**
		 * Topology element
		 */
		public static var topology:Topology;
		/**
		 * Array containing all loaded elements
		 */
		protected var elements_:Vector.<ElementBase> = new Vector.<ElementBase>();


		public function Visualizer():void
		{
			Visualizer.instance = this;
		}


		/**
		 * Tries to free all used memory. Use only when an instance of this
		 * class is not needed anymore.
		 */
		public function cleanUp():void
		{
			if (decodingTimer_ != null)
			{
				decodingTimer_.stop();
				decodingTimer_ = null;
			}
			
			trace_ = null;
			
			if (topology != null) topology.cleanUp();
			topology = null;
			
			for (var i:int = 0; i < elements_.length; i++)
			{
				if (elements_[i] != null)
				{
					elements_[i].cleanUp();
					elements_[i] = null
				}
			}
			
			if (canvasTopLayer_ != null) this.removeChild(canvasTopLayer_);
			canvasTopLayer_ = null;
			if (canvasBottomLayer_ != null) this.removeChild(canvasBottomLayer_);
			canvasBottomLayer_ = null;

			variables_ = null;
		}


		/**
		 * Fires up the asynchronous load of a trace file
		 * 
		 * @param text Contents of the trace file as a bytearray
		 */
		public function loadFromTraceFile(file:ByteArray):void
		{
			dispatchEvent(new Event(LOAD_START));
			
			this.init();
			
			Tools.log("Starting to parse trace file");
			
			trace_ = file.toString().split("\n");
			traceBytesTotal_ = file.length;
			traceLinesTotal_ = trace_.length;
			traceLinesLoaded_ = 0;
			
			// Read the first line of the trace file
			var simulationParams:Array = trace_[traceLinesLoaded_++].split(" ");
			simulationLength_ = simulationParams[1];
			
			
			// decodingTimer controls how quickly the trace file is loaded
			decodingTimer_ = new Timer(1, 1);
			decodingTimer_.addEventListener("timer", parseStep);
			decodingTimer_.start();
			
			decodingStart_ = getTimer(); // We save the beginning of the load
		}


		/**
		 * Parses a new chunk of the trace file. When it detects that the trace
		 * file is completely loaded, it initializes everything and prepares
		 * the visualizer to run
		 */
		protected function parseStep(event:Event):void
		{
			var a:uint = flash.utils.getTimer();
			var params:Array;

			// While the function has remaining execution time
			while (flash.utils.getTimer() - a < 100 && traceLinesLoaded_ < traceLinesTotal_)
			{
				params = trace_[traceLinesLoaded_++].split(" ");
				
				var e:TraceLoadEvent = new TraceLoadEvent(TRACE_LINE_FOUND, params[0], params);
				
				// The parseTraceLine_ method is called directly instead of dispatching an event
				// to improve performance. This is two times faster
				topology.parseTraceLine(e);
				for (var i:int = 0; i < elements_.length; i++)
					elements_[i].parseTraceLine(e);
			}
			
			if (traceLinesLoaded_ < traceLinesTotal_)
			{
				dispatchEvent(new ProgressEvent(LOAD_PROGRESS, false, false,
					(traceLinesLoaded_/traceLinesTotal_)*traceBytesTotal_, traceBytesTotal_));
				
				decodingTimer_.reset();
				decodingTimer_.start();
			}
			else
			{
				//jumpTo(0.0);
				
				//ready_ = true;
				
				Tools.log("Trace file loaded successfully in " + 
					Tools.msToShortString(getTimer() - decodingStart_));
				
				decodingTimer_.stop();
				decodingTimer_ = null;
				trace_ = null;
				
				dispatchEvent(new Event(LOAD_COMPLETE));
			}
			
			if (!ready)
			{
				jumpTo(0.0);
				
				ready_ = true;
			}
		}


		/**
		 * Updates the visualization. This function accepts a playbackSpeed
		 * parameter, useful to slow down or speed up the visualization
		 *
		 * @param playbackSpeed Multiplier of the elapsed time since this
		 * function was last called. For example, 2.0 = 2x velocity
		 */
		public function update(playbackSpeed:Number = 1.0):void
		{
			// If the visualization is finished, we just return
			if ((simulationTime_ < 0 && playbackSpeed < 0)
				|| (simulationTime_ > simulationLength_ && playbackSpeed > 0))
				return;
			
			if (playbackSpeed != 0)
			{
				// If this is the first time that update is called, we initialize
				// lastUpdate to "now"
				if (lastUpdate_ == 0) 
					lastUpdate_ = flash.utils.getTimer();
				
				// Now we increment the simulation time with the elapsed
				// milliseconds multiplied by the speed factor
				simulationTime_ +=
					(flash.utils.getTimer() - lastUpdate_)*playbackSpeed;
				
				// The new simulation time is checked again, in case the new one is
				// not valid
				if (simulationTime_ < 0 || simulationTime_ > simulationLength_)
				{
					dispatchEvent(new Event(FINISHED));
					return;
				}
				
			}
			
			// A TimedEvent is dispatched, containing the number of milliseconds
			// since the visualization started
			// To consume less CPU, this could be called only when 
			// playbackSpeed != 0. However, the links highlighting would stop
			// working when selecting a node with the tool paused
			dispatchEvent(new TimedEvent(STEP, simulationTime_));
			
			// Update the zoom and position of the canvas
			updateCanvas();
			
			lastUpdate_ = flash.utils.getTimer();
		}
		
		
		/**
		 * Performs a "jump in time" in the visualization
		 *
		 * @param millisecondsTotal The new moment to visualize, in milliseconds
		 */
		public function jumpTo(millisecondsTotal:uint):void
		{
			simulationTime_ = millisecondsTotal;
			
			if (simulationTime_ > simulationLength_)
				simulationTime_ = simulationLength;
			
			// A TimedEvent is dispatched, containing the number of milliseconds
			// since the visualization started
			dispatchEvent(new TimedEvent(STEP, simulationTime_));
		}
		
		
		/**
		 * Registers a new variable to be displayed in the stats window
		 */
		public function registerVariable(variable:VariableBase):void
		{
			variables_.push(variable);
		}
		
		public function getVariables():Vector.<VariableBase>
		{
			return variables_;
		}
		
		/**
		 * Whether the visualizer is ready to start visualizing or not
		 */
		public function get ready():Boolean { return ready_; }
		
		
		/**
		 * Time of the simulation displayed now, in milliseconds
		 */
		public function get simulationTime():uint { return simulationTime_ < 0 ? 0 : simulationTime_; }
		
		
		/**
		 * Length of the simulation in milliseconds
		 */
		public function get simulationLength():uint { return simulationLength_; }
		
		
		/**
		 * Level of Zoom. 1.0 means 100% zoom
		 */
		public function get zoom():Number { return zoom_; }
		/**
		 * Level of Zoom. 1.0 means 100% zoom
		 * 
		 * @param z New level of zoom
		 */
		public function set zoom(z:Number):void
		{
			if (z > 0)
				zoom_ = z;
			
			updateCanvas();
		}
		
		
		/**
		 * X Coordinate of the point to be presented in the center of the screen
		 */
		public function get targetX():int { return targetX_; }
		/**
		 * Y Coordinate of the point to be presented in the center of the screen
		 */
		public function get targetY():int { return targetY_; }
		/**
		 * X Coordinate of the point to be presented in the center of the screen
		 */
		public function set targetX(tx:int):void
		{
			targetX_ = tx;
			
			updateCanvas();
		}
		/**
		 * Y Coordinate of the point to be presented in the center of the screen
		 */
		public function set targetY(ty:int):void
		{
			targetY_ = ty;
			
			updateCanvas();
		}
		
		
		/**
		 * Progress of the simulation
		 *
		 * @return A value between 0 and 1, indicating the progress of the 
		 * visualization of the simulation
		 */
		public function get simulationProgress():Number { return simulationTime_ < 0 ? 0 : simulationTime_/simulationLength_; }
		
		
		/**
		 * Returns a vector containing elements except the topology element
		 */
		public function get elements():Vector.<ElementBase> { return elements_;}
		
		/**
		 * Initializes the visualizer. 
		 */
		protected function init():void
		{
			this.cleanUp();
			
			variables_ = new Vector.<VariableBase>();
			
			canvasTopLayer_ = new Sprite();
			canvasBottomLayer_ = new Sprite();
			addChild(canvasBottomLayer_);
			addChild(canvasTopLayer_);
			
			topology = new Topology(this, canvasTopLayer_);
			
			_roles = new Roles(this, canvasBottomLayer_);
			_nodeManager = new NodeManager();
			_sequencesManager = new SequencesManager();
			
			elements_ = new Vector.<ElementBase>();
			elements_.push(_roles);
			elements_.push(new Routing(this, canvasBottomLayer_));
			elements_.push(new Transmissions(this, canvasTopLayer_));
			elements_.push(new Receptions(this, canvasBottomLayer_));
			elements_.push(new Drops(this, null));
			elements_.push(new Buffer(this, canvasTopLayer_));
			elements_.push(new SequencesSent(this));
			elements_.push(new SequencesRecv(this));
			
			zoom_ = 1.0;
			
			lastUpdate_ = 0;
			simulationTime_ = 0;
			
			ready_ = false;
			targetX_ = 250;
			targetY_ = 250;
			lastUpdate_ = 0;
			simulationTime_ = 0;
			simulationLength_ = 1;
		}
		
		
		/**
		 * Updates the position and scaling of the main canvas so that the
		 * target is displayed in the center of the screen and with the desired
		 * zoom level
		 */
		protected function updateCanvas():void
		{
			// Apply the zoom level to the visualizer
			this.scaleX = zoom_;
			this.scaleY = zoom_;
			
			// Move the canvas to the appropriate coordinates
			canvasTopLayer_.x = -0.5*targetX_;
			canvasTopLayer_.y = -0.5*targetY_;
			canvasBottomLayer_.x = -0.5*targetX_;
			canvasBottomLayer_.y = -0.5*targetY_;
		}
		
	}
}
