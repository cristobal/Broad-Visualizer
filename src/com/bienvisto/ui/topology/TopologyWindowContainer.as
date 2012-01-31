package com.bienvisto.ui.topology
{
	import com.bienvisto.elements.network.graph.AdjacencyMatrix;
	import com.bienvisto.elements.network.graph.Edge;
	import com.bienvisto.elements.network.graph.Graph;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.topology.Topology;
	import com.bienvisto.ui.node.AdjacencyMatrixGroup;
	import com.bienvisto.view.drawing.NodeRoutingDrawingManager;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.TitleWindow;
	import spark.events.IndexChangeEvent;
	
	/**
	 * TopologyWindowContainer.as
	 * 	This is the code behind controller class for the SequencesWindow.mxml
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TopologyWindowContainer extends TitleWindow
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
			
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(CloseEvent.CLOSE, handleClose);
			
			updateTime = NodeRoutingDrawingManager.DRAW_UPDATE_TIME;
		}
		
		/**
		 * @private
		 */  
		private var node:Node;
		
		/**
		 * @private
		 */ 
		private var updateTime:uint;
		
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
		private var elapsed:uint = 0;
		
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
		private var needsInvalidation:Boolean;
		
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
			if (elapsed != time) {
				elapsed = time;
				
				// only update around 1/3 second or every 300ms.
				if ((time % updateTime) == 0) { 
					invalidate();
				}
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
		 * Setup
		 */ 
		private function setup():void
		{
			dropDownListFrom.addEventListener(IndexChangeEvent.CHANGE, handleDropDownListChange);
			dropDownListTo.addEventListener(IndexChangeEvent.CHANGE, handleDropDownListChange);
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
				graph = routing.getGlobalGraph(time);
			}
			else if ((windowType == WINDOW_TYPE_TOPOLOGY) && node) {
				graph = topology.getLocalGraph(node, time);
			}
			var adjacencyMatrix:AdjacencyMatrix;
			var path:Vector.<Edge>;
			
			if (graph) {
				adjacencyMatrix = graph.getAdjacencyMatrix();
				if (from >= 0 && to >= 0 && from != to) {
					// path = graph.findShortestPathBFS(from, to); Dijkstra is about 3x and up slower than BFS but we use it anyways talking about ms in this case
					path = graph.findShortestPathDijkstra(from, to);
					if (path) {
						pathValue = parsePath(path); // + " time:" + (getTimer() - t) + "ms";
					}
					else {
						pathValue = "–";
					}
				}
			}
			else {
				pathValue = "–";
			}
			
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
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		private function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			setup();
		}
		
		/**
		 * Handle close
		 * 
		 * @param event
		 */ 
		private function handleClose(event:CloseEvent):void
		{
			visible = false;
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
					node = nodeContainer.getNode(from);
				}
				else {
					node = null;
				}
			}
			else {
				to  = id;
			}
			setTimeout(update, 10); // call later
		}
	
	}
}