package com.bienvisto.ui.windows.node
{
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.sequences.SequencesContainer;
	import com.bienvisto.elements.topology.Topology;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.utils.Dictionary;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	/**
	 * NodeWindows.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class NodeWindows extends Group
	{
		public function NodeWindows()
		{
			super();
			setup();
		}

		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @public
		 * 	The first node window
		 */
		public var window:NodeWindow;
		
		/**
		 * @public
		 * 	The second node window
		 */ 
		public var window2:NodeWindow;
		
		/**
		 * @private
		 * 	Storage for the a window
		 */ 
		private var windowsSettings:Dictionary;
		
		/**
		 * @private
		 */ 
		private var nodeView:NodeView;
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			window = new NodeWindow();
			window.x = -(window.width + 10);
			window.visible = false;
			window.addEventListener(CloseEvent.CLOSE, handleWindowClose);
			addElement(window);
			
			window2 = new NodeWindow();
			window2.visible = false;
			window2.addEventListener(CloseEvent.CLOSE, handleWindowClose);
			addElement(window2);
			
			windowsSettings = new Dictionary();
		}
		
		/**
		 * Update selected windows
		 * 
		 * @param windows
		 */ 
		private function updateSelectedWindows():void
		{
			if (window.selectedNode) {
				storeWindowSettings(window.selectedNode, window.getSettings());		
			}
			if (window2.selectedNode) {
				storeWindowSettings(window2.selectedNode, window2.getSettings());
			}
			
			if (!nodeView.selectedNodeSprite && !nodeView.selectedNodeSprite2 && (window.selectedNode || window2.selectedNode)) {
				if (window.selectedNode) {
					window.setSelectedNode(null);
				}
				if (window2.selectedNode) {
					window2.setSelectedNode(null);
				}
				return;
			}
			
			var settings:Object;
			
			// set first node
			if (!window.selectedNode && !window2.selectedNode) {
				settings = getWindowSettings(nodeView.selectedNodeSprite);
				if (!settings) {
					settings = window.getDefaultSettings();
				}
				window.setSelectedNode(nodeView.selectedNodeSprite, settings);
			}
			// 
			else if (nodeView.selectedNodeSprite && !nodeView.selectedNodeSprite2) {
				if (window.selectedNode && (window.selectedNode.node.id == nodeView.selectedNodeSprite.node.id)) {
					window2.setSelectedNode(null);
				}
				else {
					window.setSelectedNode(null);
				}
			}
			else if (nodeView.selectedNodeSprite && nodeView.selectedNodeSprite2) {
				settings = getWindowSettings(nodeView.selectedNodeSprite2);
				if (!settings) {
					settings = window.getDefaultSettings();
				}
				
				
				if (window.selectedNode && (window.selectedNode.node.id == nodeView.selectedNodeSprite.node.id)) {
					window2.setSelectedNode(nodeView.selectedNodeSprite2, settings);
				}
				else {
					window.setSelectedNode(nodeView.selectedNodeSprite2, settings);
				}
			}

		}
		
		/**
		 * Store window settings
		 * 
		 * @param nodeSprite
		 * @param settings
		 */ 
		private function storeWindowSettings(nodeSprite:NodeSprite, settings:Object):void
		{
			var id:int = nodeSprite.node.id;
			if (id in windowsSettings) {
				delete windowsSettings[id]; // remove old settings
			}
			
			windowsSettings[id] = settings;
		}
		
		/**
		 * Get window settings
		 * 
		 * @param nodeSprite
		 */ 
		private function getWindowSettings(nodeSprite:NodeSprite):Object
		{
			var settings:Object;
			var id:int = nodeSprite.node.id;
			if (id in windowsSettings) {
				settings = windowsSettings[id];
			}
			return settings;
		}
		
		//--------------------------------------------------------------------------
		//
		// Node Window wrapper methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Set time
		 * 
		 * @param time
		 */ 
		public function setTime(time:uint):void
		{
			window.setTime(time);
			window2.setTime(time);
		}
		
		/**
		 * Set mobility
		 * 
		 * @param mobility
		 */ 
		public function setMobility(mobility:Mobility):void
		{
			window.setMobility(mobility);
			window2.setMobility(mobility);
		}
		
		/**
		 * Set routing
		 * 
		 * @param routing
		 */ 
		public function setRouting(routing:Routing):void
		{
			window.setRouting(routing);
			window2.setRouting(routing);
		}
		
		/**
		 * Set topology
		 * 
		 * @param topology
		 */ 
		public function setTopology(topology:Topology):void
		{
			window.setTopology(topology);
			window2.setTopology(topology);
		}
		
		/**
		 * Set buffers
		 * 
		 * @param buffers
		 */ 
		public function setBuffers(buffers:Buffers):void
		{
			window.setBuffers(buffers);
			window2.setBuffers(buffers);
		}
		
		/**
		 * Set transmissions
		 * 
		 * @param tranmissions
		 */ 
		public function setTransmissions(transmissions:Transmissions):void
		{
			window.setTransmissions(transmissions);
			window2.setTransmissions(transmissions);
		}
		
		/**
		 * Set receptions
		 * 
		 * @param receptions
		 */ 
		public function setReceptions(receptions:Receptions):void
		{
			window.setReceptions(receptions);
			window2.setReceptions(receptions);
		}
		
		/**
		 * Set drops
		 * 
		 * @param drops
		 */ 
		public function setDrops(drops:Drops):void
		{
			window.setDrops(drops);
			window2.setDrops(drops);
		}

		/**
		 * Set sequences container
		 * 
		 * @param sequencesContainer
		 */
		public function setSequencesContainer(sequencesContainer:SequencesContainer):void
		{
			window.setSequencesContainer(sequencesContainer);
			window2.setSequencesContainer(sequencesContainer);
		}
		
		/**
		 * Set node view
		 * 
		 * @param view
		 */ 
		public function setNodeView(view:NodeView):void
		{
			nodeView = view;
			nodeView.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSpriteSelected);	
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Events
		//
		//-------------------------------------------------------------------------
		
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
		 * Handle node sprite selected
		 * 
		 * @param event
		 */ 
		private function handleNodeSpriteSelected(event:NodeSpriteEvent):void
		{
			updateSelectedWindows();
		}
		
		/**
		 * Handle window close
		 * 
		 * @param event
		 */ 
		private function handleWindowClose(event:CloseEvent):void
		{
			updateSelectedWindows();
		}
	}
}