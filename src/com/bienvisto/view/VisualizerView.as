package com.bienvisto.view
{
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.view.components.CanvasNode;
	import com.bienvisto.view.drawing.IDrawingManager;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	/**
	 * VisualizerView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class VisualizerView extends Group
	{	
		/**
		 * 
		 */ 
		public function VisualizerView()
		{
			super();
			setup();
		}
		
		/**
		 * @private
		 */  
		private var canvas:UIComponent;
		
		/**
		 * @private
		 */ 
		private var timer:Timer;
		
		/**
		 * @private
		 */ 
		private var timerDelay:uint = 250;
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var _canvasNodes:Vector.<CanvasNode> = new Vector.<CanvasNode>();
		
		/**
		 * @readonly canvasNodes
		 */ 
		public function get canvasNodes():Vector.<CanvasNode>
		{
			return _canvasNodes.concat(); // return shallow copy	
		}
		
		/**
		 * @private
		 */ 
		private var _managers:Vector.<IDrawingManager> = new Vector.<IDrawingManager>();
		
		/**
		 * @readonly managers
		 */ 
		public function get managers():Vector.<IDrawingManager>
		{
			return _managers.concat(); // return shallow copy
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			canvas = new UIComponent();
			addElement(IVisualElement(canvas));
			
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			// timer.start();
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		/**
		 * Set node container
		 * 
		 * @param nodes
		 */ 
		public function setNodeContainer(nodeContainer:NodeContainer):void
		{
			this.nodeContainer = nodeContainer;
			invalidate();
		}
		
		/**
		 * Inavlidate
		 */ 
		private function invalidate():void
		{
			if (timer.running) {
				timer.stop();
			}
			
			// NOTE: Add additional code logic here
			
			timer.start();
		}
		
		/**
		 * Add drawing manager
		 * 
		 * @param item
		 */ 
		public function addDrawingManager(item:IDrawingManager):void
		{
			_managers.push(item);
		}
		
		/**
		 * Remove drawing manager
		 * 
		 * @param item
		 */ 
		public function removeDrawingManager(item:IDrawingManager):void
		{
			var manager:IDrawingManager;
			for (var i:int = _managers.length; i--;) {
				manager = _managers[i];
				if (manager === item) {
					_managers.splice(i, 1);
					break;
				}
			}
		}

		
		/**
		 * Background process
		 */ 
		private function process():void
		{
		
			if (nodeContainer) {
				
				// add nodes
				var nodes:Vector.<Node> = nodeContainer.nodes;
				var flag:Boolean;
				var node:Node, canvasNode:CanvasNode;
				
				for (var i:int = 0, l:int = nodes.length; i < l; i++) {
					node = nodes[i];
					flag = true;
					for (var j:int = 0, n:int = _canvasNodes.length; j < n;j++) {
						canvasNode = _canvasNodes[j];
						if (canvasNode.node.id == node.id) {
							flag = false;
							break;
						}
					}
					
					if (flag) {
						canvasNode = new CanvasNode(node);
						_canvasNodes.push(canvasNode);
						canvas.addChild(canvasNode);
					}
					
				}
				if (timer.currentCount == 2) {
					//timer.stop();
				}
			
				// remove nodes that no longer are in user
				for (i = _canvasNodes.length; i--;) {
					canvasNode = _canvasNodes[i]; 
					flag = true;
					for (j = 0, n = nodes.length; j < n; j++) {
						node = nodes[j];
						if (node.id == canvasNode.node.id) {
							flag = false;
							break;
						}
					}
					
					if (flag) {
						_canvasNodes.splice(i, 1);
						canvas.removeChild(canvasNode);
						canvasNode.destroy();
						canvasNode = null;
					}
				}
			}
		}
		
		/**
		 * Update
		 * 
		 */ 
		private function update():void
		{
			var graphics:Graphics = canvas.graphics;
			// canvas.cacheAsBitmap = false;
/*			graphics.clear();
			for each (var manager:IDrawingManager in managers) {
				manager.update(graphics, nodes);
			}*/
			// canvas.cacheAsBitmap = true;
			
			for each (var canvasNode:CanvasNode in _canvasNodes) {
				canvasNode.update();
			}
		}
		
		/**
		 * Handle timer
		 */ 
		private function handleTimer(event:TimerEvent):void
		{
			process();
		}
		
		/**
		 * Handle enter frame
		 * 
		 * @param event
		 */ 
		private function handleEnterFrame(event:Event):void
		{
			update();
		}
	}
}