package com.bienvisto.elements.drops
{
	import flash.display.Sprite;
	
	import com.bienvisto.elements.ElementBase;
	
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.core.events.TimedEvent;


	/**
	 * Class responsible of parsing the "drops" block of the trace to
	 * visualize and of actually displaying the drops in the simulation
	 */
	public class Drops extends ElementBase
	{

		/**
		 * Array of Node. Each node stores the info about its movement
		 */
		protected var nodes_:Array;
		
		protected var packetsDropped_:VariablePacketsDropped;

		/**
		 * Constructor of the class
		 * 
		 * @param visualizer Reference to the visualizer
		 */
		public function Drops(visualizer:Visualizer, canvas:Sprite)
		{
			super(visualizer, canvas);
			
			nodes_ = new Array();
			
			packetsDropped_ = new VariablePacketsDropped();
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
			return "Mac Drops";
		}
		/**
		 * @inheritDoc
		 */
		public override function get lineType():String
		{
			return "md"; // mac drop
		}


		/**
		 * Function called when a STEP event is raised. Updates the status of
		 * the transmissions data and modifies the appearance of the nodes 
		 * according to what they are transmitting
		 */
		public override function update(e:TimedEvent):void
		{
			// Update all nodes
			for each(var node:Node in nodes_)
			{
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
			
			// Check if this is a new node
			if (nodes_[nodeId] == null)
			{
				// If it is, we create it
				var newNode:Node = new Node(nodeId);
				
				// ...and we add it to the nodes list
				nodes_[nodeId] = newNode;
			}
			
			// Add the new waypoint to the node and
			var newKeypoint:PacketDrop = nodes_[nodeId].addPacketDrop(milliseconds);
			// Add the new waypoint to the variables that will be displayed 
			packetsDropped_.addKeypoint(newKeypoint);
		}

	}
}
