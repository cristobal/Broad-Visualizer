package com.gran.ui.windows.topology
{
	import com.gran.core.network.graph.AdjacencyMatrix;
	import com.gran.core.network.graph.Edge;
	import com.gran.core.network.graph.Graph;
	import com.gran.core.network.node.Node;
	import com.gran.core.network.node.NodeContainer;
	import com.gran.elements.routing.Routing;
	import com.gran.elements.topology.Topology;
	import com.gran.ui.windows.BaseWindow;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	
	/**
	 * TopologyWindowContainer.as
	 * 	This is the code behind controller class for the SequencesWindow.mxml
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TopologyWindowContainer extends BaseWindow
	{

		/**
		 * @public
		 */
		public static const WINDOW_TYPE_ROUTING:String = "routing";
		
		/**
		 * @public
		 */ 
		public static const WINDOW_TYPE_TOPOLOGY:String = "topology";
		
		public function TopologyWindowContainer()
		{
			super();
		}
		
		/**
		 * @private
		 */ 
		private var sampleTime:uint = 500;
		
		/**
		 * @private
		 */ 
		public var dropDownListFrom:DropDownList;
		
		/**
		 * @private
		 */ 
		public var dropDownListTo:DropDownList;
		
		/**
		 * @public
		 */ 
		public var adjacencyMatrixGroup:AdjacencyMatrixGroup;

		/**
		 * @private
		 */ 
		private var elapsed:Number = -1;
		
		/**
		 * @private
		 */ 
		private var from:int = int.MIN_VALUE;
		
		/**
		 * @private
		 */ 
		private var to:int = int.MIN_VALUE;
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var nodeFrom:Node;
		
		/**
		 * @private
		 */ 
		private var nodeTo:Node;
		
		/**
		 * @private
		 */ 
		private var needsInvalidation:Boolean;
		
		/**
		 * @private
		 */ 
		private var _userDefined:Boolean = false;
		
		
		/**
		 * @public
		 */ 
		public function get userDefined():Boolean
		{
			return _userDefined;
		}
		
		/**
		 * @override
		 */ 
		override public function set visible(value:Boolean):void
		{
			var flag:Boolean = !visible && value;
			super.visible = value;
			if (flag) {
				invalidate();
			}
		}
		
		/**
		 * @public
		 */ 
		public var pathValueLabel:Label;
		
		/**
		 * @write pathValue
		 */ 
		private function set pathValue(value:String):void
		{
			pathValueLabel.text = value;
		}
		
		/**
		 * Set node container
		 * 
		 * @param nodeContainer
		 */ 
		public function setNodeContainer(nodeContainer:NodeContainer):void
		{
			this.nodeContainer = nodeContainer;
			this.nodeContainer.addEventListener(Event.CHANGE, handleNodeContainerChange);
		}
		
		/**
		 * @private
		 */ 
		private var routing:Routing;
		
		/**
		 * Set routing
		 * 
		 * @param routing
		 */ 
		public function setRouting(routing:Routing):void
		{
			this.routing = routing;
		}
		
		
		/**
		 * @private
		 */ 
		private var topology:Topology;
		
		/**
		 * Set topology
		 * 
		 * @param topology
		 */ 
		public function setTopology(topology:Topology):void
		{
			this.topology = topology;
		}
		
		
		/**
		 * @private
		 */ 
		private var _time:uint = 0;
		
		public function get time():uint
		{
			return _time;
		}
		
		/**
		 * Set time
		 * 
		 * @param time
		 */ 
		public function setTime(value:uint):void
		{
			_time = value;
			value = value - (value % sampleTime); // update every half second
			if (elapsed != value) {
				elapsed = value;
				invalidate();
			}
		}
		
		/**
		 * @private
		 */ 
		private var _windowType:String = "routing";
		
		/**
		 * @readwrite windowType
		 */ 
		public function get windowType():String
		{
			return _windowType;
		}
		
		[Inspectable(type="String", defaultValue="routing", enumeration="routing,topology")]
		public function set windowType(value:String):void
		{
			if ((value != WINDOW_TYPE_ROUTING) && (value != WINDOW_TYPE_TOPOLOGY)) {
				throw(new Error("Not a valid window type"));
			}
			_windowType = value;	
		}
		
		/**
		 * @override
		 */ 
		override protected function setup():void
		{
			super.setup();
			
			dropDownListFrom.addEventListener(IndexChangeEvent.CHANGE, handleDropDownListChange);
			dropDownListTo.addEventListener(IndexChangeEvent.CHANGE, handleDropDownListChange);
		}
		
		/**
		 * @override
		 */ 
		override public function reset():void
		{
			_userDefined = false;
			needsInvalidation = false;
			elapsed = -1;
			from = int.MIN_VALUE;
			to   = int.MIN_VALUE;
			nodeFrom = null;
			nodeTo   = null;
			dropDownListFrom.dataProvider = null;
			dropDownListTo.dataProvider = null;
		}
		
		/**
		 * Set selected nodes
		 * 
		 * @param from
		 * @param to
		 */ 
		public function setSelectedNodes(from:Node, to:Node):void
		{
			if (userDefined) {
				return;
			}
			
			setNodeFrom(from);
			setNodeTo(to);
		}
		
		/**
		 * Set node from
		 * 
		 * @param from
		 */ 
		public function setNodeFrom(node:Node):void
		{
			if (userDefined) {
				return;
			}
			
			setSelectedOnDropdownList(dropDownListFrom, node);
			nodeFrom = node;		
			if (node) {
				from = node.id;
			}
			else {
				from = -1;
			}
			_userDefined = false; // restore state
			invalidate();
		}
		
		/**
		 * Set node to
		 * 
		 * @param to
		 */ 
		public function setNodeTo(node:Node):void
		{
			if (userDefined) {
				return;
			}
			
			setSelectedOnDropdownList(dropDownListTo, node);
			nodeTo = node;
			if (node) {
				to = node.id;
			}
			else {
				to = -1;
			}
			_userDefined = false; // restore state
			invalidate();
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			if (visible) {
				update();
				updateDropDownLists();
			}
		}
		
		/**
		 * Update
		 */ 
		private function update():void
		{
			if (!adjacencyMatrixGroup) {
				return;
			}
			
			
			var graph:Graph;
			if (windowType == WINDOW_TYPE_ROUTING) {
				graph = routing.getGlobalGraph(elapsed);
			}
			else if ((windowType == WINDOW_TYPE_TOPOLOGY) && nodeFrom) {
				graph = topology.getLocalGraph(nodeFrom, elapsed);
			}
			var adjacencyMatrix:AdjacencyMatrix;
			var path:Vector.<Edge>;
			
			var value:String = "–";
			if (graph) {
				adjacencyMatrix = graph.getAdjacencyMatrix();
				if (from >= 0 && to >= 0 && from != to && adjacencyMatrix && adjacencyMatrix.size > 0) {
					// path = graph.findShortestPathBFS(from, to); Dijkstra is about 3x and up slower than BFS but we use it anyways talking about ms in this case
					try {
					path = graph.findShortestPathDijkstra(from, to);
						if (path) {
							value = parsePath(path);
						}
					}
					catch(error:Error) {
						// fail silently
					}
				}
			}
			pathValue = value;
			
			adjacencyMatrixGroup.adjacencyMatrix = adjacencyMatrix;
		}
		
		/**
		 * Parse path
		 * 
		 * @param path
		 */ 
		private function parsePath(path:Vector.<Edge>):String
		{
			var value:String = "–";
			
			if (path) {
				var vertices:Vector.<int> = new Vector.<int>();
				var edge:Edge;
				for (var i:int = 0, l:int = path.length; i < l; i++) {
					edge = path[i];
					vertices.push(edge.from);
				}
				if (edge) {
					vertices.push(edge.to); // finally add destination
				}
				value = vertices.join(" -> ");
			}
			
			return value;
		}
		
		/**
		 * Update drop down lists
		 */ 
		private function updateDropDownLists():void
		{
			if (!needsInvalidation) {
				return;
			}
			needsInvalidation = false;
			
			var itemsFrom:ArrayCollection = new ArrayCollection();
			var itemsTo:ArrayCollection = new ArrayCollection();
			var nodes:Vector.<Node>  = nodeContainer.nodes;
			var node:Node;
			var total:int = 0;
			
			itemsFrom.addItem({id: -1, label: "–"});
			itemsTo.addItem({id: -1, label: "–"});
			
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node = nodes[i];
				itemsFrom.addItem({id: node.id, label: "#" + node.id});	
				itemsTo.addItem({id: node.id, label: "#" + node.id});	
				total++;
			}
			
			updateDropDownlist(dropDownListFrom, itemsFrom);
			updateDropDownlist(dropDownListTo, itemsTo);
			
			if (total == 0) {
				needsInvalidation = true; 
			}
		}
		
		/**
		 * Update drop down list
		 * 
		 * @param dropDownList
		 * @param list
		 */ 
		private function updateDropDownlist(dropDownList:DropDownList, list:ArrayCollection):void
		{
			var update:Boolean = true;
			
			var selectedItem:Object   = dropDownList.selectedItem;	
			var olist:ArrayCollection = ArrayCollection(dropDownList.dataProvider);
			if (olist) {
				
				var size:int = list.length;
				var oitem:Object, item:Object;
				if (olist.length == size) {
					update = false;
				
					for (var i:int = 0, l:int = list.length; i < size; i++) {
						oitem = olist.getItemAt(i);
						item = list.getItemAt(i);
						
						if (item.id != oitem.id || item.label != oitem.label) {
							update = true;
							break;
						}
					}
				}
				
				if (update && selectedItem) {
					for (var n:int = 0; n < size; n++) {
						item = list.getItemAt(n);
						if (item.id == selectedItem.id && item.label == selectedItem.label) {
							selectedItem = item;
							break;
						}
					}
					if (n == size) {
						selectedItem = null;
					}
				}
			}
			else {
				selectedItem = list.getItemAt(0);
			}
			
			if (update) {
				dropDownList.dataProvider = list;
				dropDownList.selectedItem = selectedItem;
			}
		}
		
		/**
		 * Set selected on dropdown list
		 * 
		 * @param list
		 * @param node
		 */ 
		private function setSelectedOnDropdownList(dropDownList:DropDownList, node:Node):void
		{
			var list:ArrayCollection = ArrayCollection(dropDownList.dataProvider);
			
			if (!node) {
				dropDownList.selectedItem = list[0];
			}
			else {
				var item:Object;
				for (var i:int = 0, l:int = list.length; i < l; i++) {
					item = list.getItemAt(i);
					if (item.id == node.id) {
						dropDownList.selectedItem = item;
						break;
					}
				}
			}
		}
		
		/**
		 * Handle node container change
		 * 
		 * @param event
		 */ 
		private function handleNodeContainerChange(event:Event):void
		{
			needsInvalidation = true;
			setTimeout(updateDropDownLists, 10); // call later
		}
		
		/**
		 * Handle drop down list change
		 * 
		 * @param event
		 */ 
		private function handleDropDownListChange(event:IndexChangeEvent):void
		{
			var dropDownList:DropDownList = DropDownList(event.target);
			var selectedItem:Object       = dropDownList.selectedItem;
			var id:int = selectedItem.id;
			if (dropDownList == dropDownListFrom) {
				from = id;
				if (from >= 1) {
					nodeFrom = nodeContainer.getNode(from);
				}
				else {
					nodeFrom = null;
				}
			}
			else {
				to  = id;
			}
			// _userDefined = true; // ucomment if we want user defined
			setTimeout(invalidate, 10); // call later
		}
	
	}
}