package com.bienvisto.elements.receptions
{
	import flash.display.Sprite;
	
	import com.bienvisto.elements.ElementBase;
	
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.core.events.TimedEvent;


	/**
	 * Class responsible of parsing the "receptions" block of the trace to
	 * visualize and of actually displaying the receptions in the simulation
	 */
	public class Receptions extends ElementBase
	{

		/**
		 * Array of Node. Each node stores the info about its movement
		 */
		protected var nodes_:Array;
		
		protected var packetsReceived_:VariablePacketsReceived;

		/**
		 * Constructor of the class
		 * 
		 * @param visualizer Reference to the visualizer
		 */
		public function Receptions(visualizer:Visualizer, canvas:Sprite)
		{
			super(visualizer, canvas);
			
			nodes_ = new Array();
			
			packetsReceived_ = new VariablePacketsReceived();
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
			return "Mac Receptions";
		}
		/**
		 * @inheritDoc
		 */
		public override function get lineType():String
		{
			return "mr"; // mac receptions
		}



		/**
		 * Function called when a STEP event is raised. Updates the status of
		 * the transmissions data and modifies the appearance of the nodes 
		 * according to what they are transmitting
		 */
		public override function update(e:TimedEvent):void
		{
			if (!visible_)
				return;
			
			// Update all nodes
			for each(var node:Node in nodes_)
			{
				// Check if the node is added to the canvas, add it if it's not
				if (!this.contains(node))
				{
					this.addChild(node);
				}
				
				// Update the node. We pass the total amount of milliseconds 
				// elapsed since the beginning of the simulation
				node.goTo(e.milliseconds);
			}
		}


		/**
		 * @inheritDoc
		 */
		protected override function loadNewLine(params:Array):void
		{
			// Get receptions data
			var nodeId:int = params[0];
			var milliseconds:uint = params[1];
			var size:Number = params[2];
			var source:int = params.length > 3 ? params[3] : -1;
			var destination:int = params.length > 4 ? params[4] : -1;
			
			// Check if this is a new node
			if (nodes_[nodeId] == null)
			{
				// If it is, we create it
				var newNode:Node = new Node(nodeId);
				
				// ...and we add it to the nodes list
				nodes_[nodeId] = newNode;
			}
			
			// Create the new keypoint
			var newKeypoint:Reception = new Reception(milliseconds, nodeId,
				source, destination, size);
			
			// Add the new keypoint to the node
			nodes_[nodeId].addReception(newKeypoint);
			
			// Add the new waypoint to the variables that will be displayed 
			// in the statistics window
			packetsReceived_.addKeypoint(newKeypoint);
		}


	}
}
