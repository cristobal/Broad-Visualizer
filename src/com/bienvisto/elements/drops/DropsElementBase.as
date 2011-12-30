package com.bienvisto.elements.drops
{
	import com.bienvisto.util.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.elements.ElementBase;
	import com.bienvisto.elements.network.Node;
	
	import flash.display.Sprite;


	/**
	 * Class responsible of parsing the "drops" block of the trace to
	 * visualize and of actually displaying the drops in the simulation
	 */
	public class DropsElementBase extends ElementBase
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
		public function DropsElementBase(visualizer:Visualizer, canvas:Sprite)
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
			for each(var node:DropNode in nodes_)
			{
				// Update the node. We pass the total amount of milliseconds 
				// elapsed since the beginning of the simulation
				node.goTo(e.elapsed);
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
			
			// Check if this is a new node
			if (nodes_[id] == null)
			{
				// Get the reference to the real node
				var node:Node = visualizer_.nodeManager.getNode(id);
				
				// If it is, we create it
				var newNode:DropNode = new DropNode(id, node);
				
				// ...and we add it to the nodes list
				nodes_[id] = newNode;
			}
			
			// Add the new waypoint to the node and
			var newKeypoint:PacketDrop = nodes_[id].addPacketDrop(milliseconds);
			// Add the new waypoint to the variables that will be displayed 
			packetsDropped_.addKeypoint(newKeypoint);
		}

	}
}
