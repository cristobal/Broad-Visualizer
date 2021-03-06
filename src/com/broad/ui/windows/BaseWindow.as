package com.broad.ui.windows
{	
	import flash.display.DisplayObject;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.SandboxMouseEvent;
	import mx.graphics.SolidColor;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.TitleWindow;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Path;
	import spark.skins.spark.TitleWindowSkin;
	
	/**
	 * @Event
	 * 	Triggered when window has toggled its visibility
	 */ 
	[Event(name="toggle", type="flash.events.Event")]

	/**
	 * BaseWindow.as
	 * 	The base window class for all the floating windows in the application.
	 *  Manages properties such as moving and constraining the movement area.
	 *  In addition to the resizing of the windows.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class BaseWindow extends TitleWindow
	{
		
		//--------------------------------------------------------------------------
		//
		// Class Constants
		//
		//-------------------------------------------------------------------------
		/**
		 * @public
		 */ 
		public static const TOGGLE:String = "toggle";
		
		//--------------------------------------------------------------------------
		//
		// Class Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var offsetTop:Number = 30;
		
		/**
		 * @private
		 */ 
		private static var offsetBottom:Number = 20 + offsetTop;
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */ 
		public function BaseWindow()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			addEventListener(CloseEvent.CLOSE, handleClose);	
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @protected
		 */ 
		protected var positionFixed:Boolean = false;
		
		/**
		 * @protected
		 */ 
		protected var resized:Boolean = false;
		
		/**
		 * @protected
		 */ 
		protected var resizeHandle:Group;
		
		/**
		 * @protected
		 */
		protected var resizeListener:Boolean = false;
		
		/**
		 * @protected
		 */ 
		protected var resizeRectangle:Rectangle;
		
		/**
		 * @protected
		 */ 
		protected var parentRectangle:Rectangle;
		
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------------
		
		//----------------------------------
		//  defaultAsFloatingWindow
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _defaultAsFloatingWindow:Boolean = true;
		
		/**
		 * @readonly get registeredAsPopUp
		 * 	Wether this component has been registered as a floating window
		 */ 
		public function get defaultAsFloatingWindow():Boolean
		{
			return _defaultAsFloatingWindow;
		}
		
		public function set defaultAsFloatingWindow(value:Boolean):void
		{
			_defaultAsFloatingWindow = value;
		}
		
		//----------------------------------
		//  registeredAsFloatingWindow
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _registeredAsFloatingWindow:Boolean = false;
		
		/**
		 * @readonly get registeredAsPopUp
		 * 	Wether this component has been registered as a popup element
		 */ 
		public function get registeredAsFloatingWindow():Boolean
		{
			return _registeredAsFloatingWindow;
		}
		
		//----------------------------------
		//  resizable
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _resizable:Boolean = true;
		
		/**
		 * @readwrite get _resizable
		 * 	Wether this component has been registered as a popup element
		 */ 
		public function get resizable():Boolean
		{
			return _resizable;
		}
		
		public function set resizable(value:Boolean):void
		{
			if (resizable != value) {
				_resizable = value;
				invalidateResizable();
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		protected function setup():void
		{
			// set the style
			var titleWindowSkin:TitleWindowSkin = TitleWindowSkin(skin); 
			titleWindowSkin.dropShadow.blurX = 10;
			titleWindowSkin.dropShadow.blurY = 5;
			titleWindowSkin.dropShadow.distance = 7;
			titleWindowSkin.titleDisplay.minHeight = 28;
			// HorizontalLayout(titleWindowSkin.controlBarGroup.layout).paddingBottom = 0;
			// HorizontalLayout(titleWindowSkin.controlBarGroup.layout).gap = 0;
			
			resizeHandle = new Group();
			resizeHandle.width  = 15;
			resizeHandle.height = 15;
			resizeHandle.setStyle("right", 0);
			resizeHandle.setStyle("bottom", 0);
			
			var path:Path = new Path();
			path.data = "M 2 13 L 13 2 L 13 13 L 2 13";
			path.fill = new SolidColor(0x333333);
			resizeHandle.addElement(path);
			
			contentGroup.addElement(resizeHandle);	
			resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, handleResizeMouseDown);
			invalidateResizable();
			
			
			minWidth  = width;
			minHeight = height; 
			
			if (defaultAsFloatingWindow) {
				registerAsFloatingWindow();
			}
		}
		
		/**
		 * Hide
		 */ 
		public function hide():void
		{
			super.visible = false;
		}
		
		/**
		 * Hide
		 */ 
		public function show():void
		{
			super.visible = true;
		}
		
		/**
		 * Toggle
		 */ 
		public function toggle():void
		{
			visible = !visible;
			dispatchEvent(new Event(TOGGLE));
		}
		
		/**
		 * On close
		 */ 
		protected function onClose():void
		{
			visible = false;
		}
		
		/**
		 * Register as popup
		 */ 
		protected function registerAsFloatingWindow():void
		{
			TitleWindowSkin(skin).topGroup.addEventListener(MouseEvent.MOUSE_DOWN, handleTopGroupMouseDown);
			_registeredAsFloatingWindow = true;
		}
		
		/**
		 * Invalidate resizable
		 */ 
		protected function invalidateResizable():void
		{
			if (resizeHandle) {
				resizeHandle.visible = resizable;
			}
		}
		
		/**
		 * Set initial position
		 * 
		 * @param top
		 * @param right
		 * @param bottom
		 * @param left
		 */ 
		public function setInitialPosition(top:*, right:*, bottom:*, left:*):void
		{
			
			setStyle("top", top);
			setStyle("right", right);
			setStyle("bottom", bottom);
			setStyle("left", left);

			positionFixed = true;
			invalidateResizeListener();
		}
		
		/**
		 * Invalidate position fixed
		 */ 
		public function invalidatePositionFixed():void 
		{
			setStyle("top", "");
			setStyle("right", "");
			setStyle("bottom", "");
			setStyle("left", "");
			
			positionFixed = false;
			invalidateResizeListener();
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			
		}
		
		/**
		 * Invalidate resize listener
		 */ 
		protected function invalidateResizeListener():void
		{
			if (!stage) {
				return;
			}
			
			if (positionFixed && !resizeListener) {
				stage.addEventListener(Event.RESIZE, handleStageResize, true);
				resizeListener = false;
			}
			else if (!positionFixed && resizeListener) {
				stage.removeEventListener(Event.RESIZE, handleStageResize, true);
				resizeListener = false;
			}
		}
		
		/**
		 * On resize changed
		 */ 
		protected function onResizeChange():void
		{
			
		}
		
		
		/**
		 * Move to
		 * 
		 * @param dx
		 * @param dy
		 */ 
		protected function moveTo(dx:int, dy:int):void
		{
			var pw:Number = parentRectangle ? parentRectangle.width : parent.width;
			var ph:Number = parentRectangle ? parentRectangle.height : parent.height;
			
			if (dx < 0) {
				x = 0;
			}
			else if (x > (parent.width - width)) {
				x = parent.width - width;	
			}
			else {
				x = dx;
			}
			
			if (dy < offsetTop) {
				y = offsetTop;
			}
			else if (dy > parent.height - (height + offsetBottom)) {
				y = parent.height - (height + offsetBottom);
			}
			else {
				y = dy;
			}
			
			// restore val
			parent.width  = pw;
			parent.height = ph;
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
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			setup();
		}
		
		/**
		 * Handle added to stage
		 * 
		 * @param event
		 */ 
		protected function handleAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
		}
		
		/**
		 * Handle removed from stage
		 * 
		 * @param event
		 */ 
		protected function handleRemovedFromStage(event:Event):void
		{
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			_registeredAsFloatingWindow = false;
		}
		
		/**
		 * Handle fullScreen event
		 * 
		 * @param event
		 */ 
		protected function handleFullScreenEvent(event:FullScreenEvent):void
		{
			if (stage.displayState == StageDisplayState.NORMAL) {
				moveTo(x, y); // after exiting fullscreen check if current position is ok.
			}
		}
		
		/**
		 * Handle stage resize
		 * 
		 * @param event
		 */ 
		protected function handleStageResize(event:Event):void
		{
			parentRectangle = new Rectangle(0, 0, parent.width, parent.height);
			resized 		= true;
		}
		
		/**
		 * Handle close
		 * 
		 * @param event
		 */ 
		protected function handleClose(event:CloseEvent):void
		{
			onClose();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Drag/Move Event handling
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var lastMovePoint:Point;
		
		/**
		 * Handle top group mouse down
		 * 
		 * @param event
		 */ 
		protected function handleTopGroupMouseDown(event:MouseEvent):void
		{
			var root:DisplayObject = systemManager.getSandboxRoot();
			root.addEventListener(MouseEvent.MOUSE_MOVE, handleTopGroupMouseMove);
			root.addEventListener(MouseEvent.MOUSE_UP, handleTopGroupMouseUp);
			root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleTopGroupMouseUp);
			
			lastMovePoint = new Point(event.stageX, event.stageY);
			
			try {
				Group(parent).addElementAt(this, Group(parent).numElements - 1); // move to top	
			}
			catch (error:Error){/* fail silently; should not happen */}
		}
		
		/**
		 * Handle top group mouse down
		 * 
		 * @param event
		 */
		protected function handleTopGroupMouseMove(event:MouseEvent):void
		{
			invalidatePositionFixed();
			
			var stageX:Number = event.stageX;
			var stageY:Number = event.stageY;
			
			var dx:Number = stageX - lastMovePoint.x;
			var dy:Number = stageY - lastMovePoint.y;
			
			moveTo(x + dx, y + dy);
			
			lastMovePoint = new Point(stageX, stageY);
		}
		
		/**
		 * Handle top group mouse down
		 * 
		 * @param event
		 */
		protected function handleTopGroupMouseUp(event:MouseEvent):void
		{
			var root:DisplayObject = systemManager.getSandboxRoot();
			root.removeEventListener(MouseEvent.MOUSE_MOVE, handleTopGroupMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, handleTopGroupMouseUp);
			root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleTopGroupMouseUp);
		}
		
		//--------------------------------------------------------------------------
		//
		// Resize event handling
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle resize mouse down
		 * 
		 * @param event
		 */ 
		protected function handleResizeMouseDown(event:MouseEvent):void
		{
			if (!resizeRectangle) {
				resizeRectangle = new Rectangle(event.stageX, event.stageY, width, height);
				var root:DisplayObject = systemManager.getSandboxRoot();
				
				
				root.addEventListener(MouseEvent.MOUSE_MOVE, handleResizeMouseMove);
				root.addEventListener(MouseEvent.MOUSE_UP, handleResizeMouseUp);
				root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleResizeMouseUp);
			}
		}
		
		/**
		 * Handle resize mouse move
		 * 
		 * @param event
		 */ 
		protected function handleResizeMouseMove(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			
			if (!resizeRectangle) {
				return;
			}
			
			var w:Number = resizeRectangle.width + (event.stageX - resizeRectangle.x);
			var h:Number = resizeRectangle.height + (event.stageY - resizeRectangle.y);
			if (y + h > parent.height - offsetBottom) {
				h = (parent.height - offsetBottom) - y;
			}
			
			var parentHeight:Number = parent.height;
			
			width  = w < minWidth ? minWidth : w;
			height = h < minHeight ? minHeight : h;
			
			parent.height = parentHeight; // restore parent height
			event.updateAfterEvent();
			
			onResizeChange();
			if (positionFixed) {
				invalidatePositionFixed();
			}
		}
		
		/**
		 * Handle resize mouse up
		 * 
		 * @param event
		 */ 
		protected function handleResizeMouseUp(event:Event):void
		{
			resizeRectangle = null;
			
			var root:DisplayObject = systemManager.getSandboxRoot();
			
			root.removeEventListener(MouseEvent.MOUSE_MOVE, handleResizeMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, handleResizeMouseUp);
			root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleResizeMouseUp);		
		}
		

	}
}