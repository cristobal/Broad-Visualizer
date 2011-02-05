package com.bienvisto.elements.template_element
{
	import flash.display.Sprite;
	
	import com.bienvisto.elements.ElementBase;
	
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.events.TimedEvent;


	/**
	 * Template element class to facilitate the creation of new elements.
	 * There are instruction on what to do in the comments
	 */
	public class TemplateElement extends ElementBase // <- change the name of the class
	{
		/**
		 * Array of Node. Each node stores the info about its movement
		 * This is optional but highly recommended if you want to follow the 
		 * same design of the rest of the elements
		 */
		protected var nodes_:Array;

		/**
		 * Constructor of the class
		 * 
		 * @param visualizer Reference to the visualizer
		 */
		public function Topology(visualizer:Visualizer, canvas:Sprite)
		{
			super(visualizer, canvas);
			
			nodes_ = new Array();
			
			// If you have variables for the Charting System this is the best
			// place to construct them. See Receptions.as for an example
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
			return "Template"; // <- put the name of this element here
		}
		/**
		 * @inheritDoc
		 */
		public override function get lineType():String
		{
			return "xx"; // <- put the id of the event types in the trace file
		}


		/**
		 * Function called when a STEP event is raised. 
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
			// "params" contains the parameters of the trace line but with the
			// event type id removed. If you followed the guidelines on how to
			// extend the trace file, the node id will be in params[0]
			var nodeId:int = params[0];
			// ... read other parameters of the event here
			
			// Check if this is a new node
			if (nodes_[nodeId] == null)
			{
				// If it is, we create it
				var newNode:Node = new Node(nodeId);

				// ...and we add it to the nodes list
				nodes_[nodeId] = newNode;
			}
			
			// Add the new keypoint to the node here
			
			// If this element has variables for the charting system, the new
			// keypoint should be inserted in the variable here
			// See Receptions.as for an example
		}


	}
}
