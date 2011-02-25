package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.elements.ElementBase;
	import com.bienvisto.elements.Node;
	
	import flash.display.Sprite;


	/**
	 * Class responsible of parsing the "buffer" block of the trace to
	 * visualize and of actually displaying buffer data in the visualization
	 */
	public class Buffer extends ElementBase
	{

		/**
		 * Array of Node. Each node stores the info about its movement
		 */
		protected var nodes_:Array;
		
		protected var bufferSize_:VariableBufferSize;

		/**
		 * Constructor of the class
		 * 
		 * @param visualizer Reference to the visualizer
		 */
		public function Buffer(visualizer:Visualizer, canvas:Sprite)
		{
			super(visualizer, canvas);
			
			nodes_ = new Array();
			
			bufferSize_ = new VariableBufferSize();
			
			mouseEnabled = false;
			mouseChildren = false;
		}


		/**
		 * Tries to free all used memory. Use only when an instance of this
		 * class is not needed anymore.
		 */
		public override function cleanUp():void
		{
			super.cleanUp();
			nodes_ = null;
		}


		/**
		 * @inheritDoc
		 */
		public override function get name():String
		{
			return "Buffer";
		}
		/**
		 * @inheritDoc
		 */
		public override function get lineType():String
		{
			return "be"; // buffer enqueue(/change?)
		}


		/**
		 * Function called when a STEP event is raised. Updates the status of
		 * the transmissions data and modifies the appearance of the nodes 
		 * according to what they are transmitting
		 */
		public override function update(e:TimedEvent):void
		{
			// Update all nodes
			for each(var node:BufferNode in nodes_)
			{
				// Update the node. We pass the total amount of milliseconds 
				// elapsed since the beginning of the simulation
				node.goTo(e.milliseconds);
				
				addChild(node);
			}
		}


		/**
		 * @inheritDoc
		 */
		protected override function loadNewLine(params:Array):void
		{
			// Get receptions data
			var id:int = params[0];
			var milliseconds:uint = params[1];
			var currentSize:Number = params[2];
			
			// Check if this is a new node
			if (nodes_[id] == null)
			{
				// Get the real node
				var node:Node = visualizer_.nodeManager.findNodeById(id);
				
				// If it is, we create it
				var newNode:BufferNode = new BufferNode(id, node);
				
				// ...and we add it to the nodes list
				nodes_[id] = newNode;
			}
			
			// Add the new waypoint to the node and
			var newKeypoint:BufferChange = nodes_[id].addBufferChange(milliseconds, currentSize);
			// Add the new waypoint to the variables that will be displayed 
			bufferSize_.addKeypoint(newKeypoint);
		}


	}
}
