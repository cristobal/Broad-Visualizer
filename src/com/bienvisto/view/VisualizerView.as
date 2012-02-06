package com.bienvisto.view
{
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.view.components.MiniMapView;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.ViewComponent;
	import com.bienvisto.view.drawing.IDrawingManager;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.effects.Tween;
	
	import spark.components.Group;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.EaseInOutBase;
	
	/**
	 * VisualizerView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class VisualizerView extends Group
	{	
		/**
		 * VisualizerView
		 */ 
		public function VisualizerView()
		{
			super();
			setup();
		}
		
		/**
		 * @private
		 */ 
		private var _viewComponents:Vector.<ViewComponent> = new Vector.<ViewComponent>();
		
		/**
		 * @readonly viewComponents
		 */ 
		public function get viewComponents():Vector.<ViewComponent>
		{
			return  _viewComponents;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint = 0;
		
		/**
		 * @readwrite time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		public function setTime(time:uint):void
		{
			_time = time;
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{	
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		
		/**
		 * Add a view component
		 * 
		 * @param item
		 */ 
		public function addViewComponent(item:ViewComponent):void
		{
			_viewComponents.push(item);
			addElement(item);
		}
		
		
		/**
		 * Remove view component
		 * 
		 * @param item
		 */ 
		private function removeViewComponent(item:ViewComponent):void
		{
			var view:ViewComponent;
			for (var i:int = _viewComponents.length; i--;) {
				item = _viewComponents[i];
				if (view === item) {
					_viewComponents.splice(i, 1);
					removeElement(view);
				}
			}
		}
		
		/**
		 * Update
		 */ 
		private function update():void
		{	
			var tt:int = getTimer();
			var viewComponent:ViewComponent;
			for (var i:int = 0, l:int = _viewComponents.length; i < l; i++) {
				viewComponent = _viewComponents[i];
				viewComponent.update(time);
			}
			if (s != time) {
				s = time;
				sum += (getTimer() - tt);
				total++;
				if (total % 10 == 0) {
					trace("Avg update time:", String(sum / total), "ms");
				}
				
			}
		}
		
		private var total:Number = 0;
		private var sum:Number = 0;
		private var s:int      = -1;
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			width  = parent.width;
			height = parent.height;
			
			var viewComponent:ViewComponent;
			for (var i:int = 0, l:int = _viewComponents.length; i < l; i++) {
				viewComponent = _viewComponents[i];
				viewComponent.invalidateSize();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Mini map view
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var miniMapView:ViewComponent;
		
		
		/**
		 * Set loader view
		 * 
		 * @param view
		 */ 
		public function setMiniMapView(view:ViewComponent):void
		{
			miniMapView = view;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Loader view
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var loaderView:ViewComponent;
		
		/**
		 * @readwrite loaderViewVisible
		 */ 
		public function get loaderViewVisible():Boolean
		{
			var value:Boolean;
			
			if (loaderView) {
				value = loaderView.visible;
			}
			
			return value;
		}
		
		public function set loaderViewVisible(value:Boolean):void
		{
			if (loaderView) {
				loaderView.visible = value;
				invalidateLoaderView();
			}
		}
		
		/**
		 * Set loader view
		 * 
		 * @param view
		 */ 
		public function setLoaderView(view:ViewComponent):void
		{
			loaderView = view;
			loaderView.visible = false; // initialize as hidden
		}
		
		/**
		 * Setup loader view
		 */ 
		private function invalidateLoaderView():void
		{
			addElementAt(loaderView, numElements - 1);
			if (parent) {
				loaderView.setSize(parent.width, parent.height);
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Draggable view
		//
		//--------------------------------------------------------------------------
		
		private var draggableView:ViewComponent;
		private var draggable:Boolean = false;
		private var isDragging:Boolean = false;
		private var dragX:Number;
		private var dragY:Number;
		private var dragTimer:Timer;
		private var dragTimerDelay:Number = 120;
		
		public function setDraggableView(view:ViewComponent):void
		{
			draggableView = view;	
			setupDraggableView();
		}
		
		
		private function setupDraggableView():void
		{
			// mouseEnabled = true;
			
			dragTimer = new Timer(dragTimerDelay, 1);
			dragTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleDragTimerComplete);
			
			addEventListener(MouseEvent.CLICK, handleMouseClick);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
		}
		
		private function handleDragTimerComplete(event:TimerEvent):void
		{
			if (draggable) {
				Mouse.cursor = MouseCursor.HAND;
				isDragging = true;
			}
		}
		
		/**
		 * Handle mouse click
		 * 
		 * @param event
		 */ 
		private function handleMouseClick(event:MouseEvent):void
		{
			if (miniMapView && !miniMapView.visible) {
				return;
			}
			
	
				
			var sx:Number  = event.stageX;
			var sy:Number  = event.stageY;
			
			var w:Number   = miniMapView.width;
			var h:Number   = miniMapView.height;
			
			var dx:Number  = miniMapView.x;
			var dx2:Number = dx + w;
			var dy:Number  = miniMapView.y;
			var dy2:Number = dy + h;
			if (sx > dx && sx < dx2 && sy > dy && sy < dy2) {
				var rect:Rectangle = MiniMapView(miniMapView).displacedRect;
				if (rect && rect.width > 0 && rect.height > 0) {
					
					// TODO: Tune Pan to
					
					var aw:Number = rect.width;
					var ah:Number = rect.height;
						
					var tx:Number = (sx - dx);
					var ty:Number = (sy - dy);
					
					tx *= aw / w;
					ty *= ah / h;
					
					var cx:Number = draggableView.x;
					var cy:Number = draggableView.y;
					
					var pw:Number = parent.width;
					var ph:Number = parent.height;
					var px:Number = pw / 2;
					var py:Number = ph / 4;
					
					var animate:Animate = new Animate(draggableView);
					var easer:EaseInOutBase = new EaseInOutBase();
					animate.easer = easer;
					
					var nx:Number;
					if (tx > cx || tx > px) {
						nx = -tx + px;
					}
					else {
						nx = tx  + px;
					}
/*					var ny:Number;
					if (ty > cy || ty > py) {
						ny = ty + py;
					}
					else {
						ny = -ty + py;
					}
					*/
					animate.motionPaths = Vector.<MotionPath>([
						new SimpleMotionPath("x", cx, nx)
						// new SimpleMotionPath("y", cy, ny)
					]);
					
					animate.play();
					// trace("cx:", cx, "tx:", tx);
				}
			}
			
		}
		
		/**
		 * Handle mouse down
		 * 
		 * @param event
		 */ 
		private function handleMouseDown(event:MouseEvent):void
		{
			if (!draggable) {
				dragX = event.stageX;
				dragY = event.stageY;
				draggable = true;
				dragTimer.start();
			}
		}
		
		/**
		 * Handle mouse up
		 * 
		 * @param event
		 */ 
		private function handleMouseUp(event:MouseEvent):void
		{
			if (dragTimer.running) {
				dragTimer.stop();
			}
			Mouse.cursor = MouseCursor.AUTO;
			// if (isDragging) {
			draggable  = false;	
			isDragging = false;
			// }
		}
		
		/**
		 * Handle mouse move
		 * 
		 * @param event
		 */ 
		private function handleMouseMove(event:MouseEvent):void
		{
			if (!draggable) {
				return;
			}
			var stageY:Number = event.stageY;
			var stageX:Number = event.stageX;
			var topOffset:Number = 60;
			var bottomOffset:Number = parent.height - 60;
			
			if (isDragging) {
				var dx:Number = (stageX - dragX) / 32;
				var dy:Number = (stageY - dragY) / 32;
				
				draggableView.x += dx;
				draggableView.y += dy;
			}
		}
		
		/**
		 * Handle mouse out
		 * 
		 * @param event
		 */ 
		private function handleMouseOut(event:MouseEvent):void
		{
			if (!isDragging) {
				Mouse.cursor = MouseCursor.AUTO;
				draggable = false;
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Timer
		//
		//--------------------------------------------------------------------------
		
		public function start():void
		{
			
		}
		
		public function pause():void
		{
			
		}
		
		public function stop():void
		{
			
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Events
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Handle enter frame
		 * 
		 * @param event
		 */ 
		private function handleEnterFrame(event:Event):void
		{
			update();
		}
		
		/**
		 * Handle resize
		 */ 
		private function handleResize(event:Event):void
		{
			invalidate();	
			invalidateLoaderView();
		}
		
		/**
		 * Handle added to stage
		 * 
		 * @param event
		 */ 
		private function handleAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			parent.addEventListener(Event.RESIZE, handleResize);
			invalidate();
		}
		
	}
}