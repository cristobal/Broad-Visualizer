package com.bienvisto.elements.topology
{
	import com.bienvisto.UIComponents.node.NodeWindow;
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.events.TraceLoadEvent;
	import com.bienvisto.elements.ElementBase;
	import com.bienvisto.elements.roles.NodeRole;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import spark.components.Application;


	/**
	 * Class responsible of parsing the "topology" block of the trace to
	 * visualize and of actually displaying the topology of the simulation
	 */
	public class Topology extends ElementBase
	{
		/**
		 * Array of Node. Each node stores the info about its movement
		 */
		protected var nodes_:Array;

		/**
		 * Vector containing all ids of all selected nodes
		 */
		protected var selectedNodes_:Vector.<int>;

		/**
		 * Constructor of the class
		 * 
		 * @param visualizer Reference to the visualizer
		 */
		public function Topology(visualizer:Visualizer, canvas:Sprite)
		{
			super(visualizer, canvas);
			
			nodes_ = new Array();
			selectedNodes_ = new Vector.<int>();
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
			return "Topology";
		}
		/**
		 * @inheritDoc
		 */
		public override function get lineType():String
		{
			return "cc"; // course change
		}


		/**
		 * Position of some node, given its id
		 */
		public function getNodePosition(nodeId:int):Vector2D
		{
			if (nodes_[nodeId] == null)
				return null;
			
			return nodes_[nodeId].position;
		}
		
		/**
		 * True if the node is selected
		 */
		public function isNodeSelected(nodeId:int):Boolean
		{
			if (nodes_[nodeId] == null)
				return false;
			
			return nodes_[nodeId].selected;
		}
		
		
		/**
		 * Returns the ids of all selected nodes
		 *
		 * @return Vector containing all ids of all selected nodes
		 */
		public function get selectedNodes():Vector.<int>
		{
			return selectedNodes_;
		}
		
		/**
		 * Highlights a node for half a second, approximately
		 *
		 * @param nodeId Id of the node to highlight
		 * @param color Color used to highlight the node. If null, the default
		 * color will be used
		 */
		public function highlightNode(nodeId:int, color:uint = 0xFFCC00):void
		{
			if (nodes_[nodeId] != null)
				nodes_[nodeId].highlight(color);
		}


		/**
		 * Function called when a STEP event is raised. This means that all 
		 * topology elements must be updated
		 */
		public override function update(e:TimedEvent):void
		{
			// Update all nodes
			for each(var node:Node in nodes_)
			{
				// Check if the node is added to the canvas, add it if it's not
				if (!this.contains(node))
				{
					this.addChild(node);
					node.addEventListener(MouseEvent.CLICK, nodeClicked);
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
			var position:Vector2D = new Vector2D(params[2],	params[3]);
			var direction:Vector2D = new Vector2D(params[4], params[5]);
			
			// Check if this is a new node
			if (nodes_[nodeId] == null)
			{
				// Find its nodeRole
				var nodeRole:NodeRole = visualizer_.roles.findRoleById(nodeId);
				
				// If it is, we create it
				var newNode:Node = new Node(nodeId, nodeRole);
				newNode.x = position.x;
				newNode.y = position.y;

				// ...and we add it to the nodes list
				nodes_[nodeId] = newNode;

			}
			
			// Add the new waypoint to the node
			nodes_[nodeId].addWaypoint(position, direction, milliseconds);
		}


		/**
		 * Handles the event of a node being clicked
		 */
		protected function nodeClicked(e:MouseEvent):void
		{
			var node:Node = e.target as Node;
			
			node.selected = !node.selected;
			
			if (node.selected)
				selectedNodes_.push(node.id);
			else
				selectedNodes_.splice(selectedNodes_.indexOf(node.id), 1);
			
			visualizer_.update(0);
			
			visualizer_.dispatchEvent(new Event(Visualizer.NODE_CLICKED));
		
			// TODO: Move this outside of the topology and refactor the node classes to one.
			var method:String = "setSelectedNode";
			FlexGlobals.topLevelApplication["nodeWindow"][method](node);
			
			
		}


	}
}
