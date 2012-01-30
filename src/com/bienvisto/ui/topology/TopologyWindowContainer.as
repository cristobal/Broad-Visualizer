package com.bienvisto.ui.topology
{
	import com.bienvisto.elements.network.graph.AdjacencyMatrix;
	import com.bienvisto.elements.network.graph.Edge;
	import com.bienvisto.elements.network.graph.Graph;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.ui.node.AdjacencyMatrixGroup;
	
	import flash.events.Event;
	
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
		public function TopologyWindowContainer()
		{
			super();
			
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
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
		
		public var labelDijkstra:Label;
		
		private function set pathValueDijkstra(value:String):void
		{
			labelDijkstra.text = value;
		}
		
		public var labelBSF:Label;
		
		/**
		 * 
		 */ 
		private function set pathValueBSF(value:String):void
		{
			labelBSF.text = value;
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
				
				// only update every half second.
				if ((time % 500) == 0) { 
					update();
					if (needsInvalidation) {
						updateDropDownLists();
						needsInvalidation = false;
					}
				}
			}
			
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
		 * Update
		 */ 
		private function update():void
		{
			if (!adjacencyMatrixGroup) {
				return;
			}
			
			var graph:Graph = routing.getGlobalGraph(time);
			var adjacencyMatrix:AdjacencyMatrix;
			var path:Vector.<Edge>;
			
			if (graph) {
				adjacencyMatrix = graph.getAdjacencyMatrix();
				
				if (from >= 0 && to >= 0) {
					path = graph.findShortestPathDijkstra(from, to);
					if (path) {
						pathValueDijkstra = parsePath(path);
					}
					path = graph.findShortestPathBFS(from, to);
					if (path) {
						pathValueBSF = parsePath(path);
					}
				}
			}
			else {
				pathValueDijkstra = "–";
				pathValueBSF = "–";
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
			var itemsFrom:ArrayCollection = new ArrayCollection();
			var itemsTo:ArrayCollection = new ArrayCollection();
			var nodes:Vector.<Node>  = nodeContainer.nodes;
			var node:Node;
			
			itemsFrom.addItem({id: -1, label: "–"});
			itemsTo.addItem({id: -1, label: "–"});
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node = nodes[i];
				itemsFrom.addItem({id: node.id, label: "#" + node.id});	
				itemsTo.addItem({id: node.id, label: "#" + node.id});	
			}
			
			updateDropDownlist(dropDownListFrom, itemsFrom);
			updateDropDownlist(dropDownListTo, itemsTo);
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
			}
			else {
				to  = id;
			}
			// trace("from:", from, "to:", to);
			update();
		}
	
	}
}