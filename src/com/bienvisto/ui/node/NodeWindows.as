package com.bienvisto.ui.node
{
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.sequences.SequencesRecv;
	import com.bienvisto.elements.sequences.SequencesSent;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.utils.Dictionary;
	
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
			window.visible = false;
			addElement(window);
			
			window2 = new NodeWindow();
			window2.x = -(window.width + 10);
			window2.visible = false;
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
			window.setSelectedNode(nodeView.selectedNodeSprite);
			window2.setSelectedNode(nodeView.selectedNodeSprite2);
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
		 * Set sequences recv
		 * 
		 * @param sequencesRecv
		 */
		public function setSequencesRecv(sequencesRecv:SequencesRecv):void
		{
			window.setSequencesRecv(sequencesRecv);
			window2.setSequencesRecv(sequencesRecv);
		}
		
		/**
		 * Set sequences sent
		 * 
		 * @param sequencesSent
		 */ 
		public function setSequencesSent(sequencesSent:SequencesSent):void
		{
			window.setSequencesSent(sequencesSent);
			window2.setSequencesSent(sequencesSent);
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
			// var nodeSprite:NodeSprite = event.nodeSprite;
			// window.setSelectedNode(event.nodeSprite);
		}
	}
}