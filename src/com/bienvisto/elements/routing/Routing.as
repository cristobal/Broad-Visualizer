package com.bienvisto.elements.routing
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.elements.ElementBase;
	import com.bienvisto.elements.Node;
	import com.bienvisto.util.Tools;
	
	import flash.display.Sprite;


	/**
	 * Class responsible of parsing the "routing" block of the trace to
	 * visualize and of actually displaying routing information (links between
	 * nodes)
	 */
	public class Routing extends ElementBase
	{

		/**
		 * Array of Node. Each node stores an array of routing tables
		 */
		protected var nodes_:Array;


		/**
		 * Constructor of the class
		 * 
		 * @param visualizer Reference to the visualizer
		 */
		public function Routing(visualizer:Visualizer, canvas:Sprite)
		{
			super(visualizer, canvas);
			
			nodes_ = new Array();
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
			return "Routing";
		}
		/**
		 * @inheritDoc
		 */
		public override function get lineType():String
		{
			return "rc"; // route change
		}


		/**
		 * Function called when a STEP event is raised. This means that all 
		 * links will be updated
		 */
		public override function update(e:TimedEvent):void
		{
			if (!visible_)
				return;
			
			if (e.milliseconds == 0) return;
			
			// Update all nodes
			for each(var node:RoutingNode in nodes_)
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
			// Get waypoint data
			var nodeId:int = params[0];
			var milliseconds:uint = params[1];
			var table:String = params[2];
			
			// Check if this is a new node
			if (nodes_[nodeId] == null)
			{
				// If it is, we create it
				var node:Node = visualizer_.nodeManager.findNodeById(nodeId);
				var newNode:RoutingNode = new RoutingNode(nodeId, node);

				// ...and we add it to the nodes list
				nodes_[nodeId] = newNode;
			}
			
			// Add the new keypoint to the node
			nodes_[nodeId].addTable(table, milliseconds);
		}

	}

}


