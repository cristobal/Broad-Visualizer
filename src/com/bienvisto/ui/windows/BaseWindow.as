package com.bienvisto.ui.windows
{
	import avmplus.getQualifiedClassName;
	
	import com.bienvisto.ApplicationWindow;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	import mx.events.SandboxMouseEvent;
	import mx.graphics.SolidColor;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.TitleWindow;
	import spark.primitives.Path;
	
	/**
	 * BaseWindow.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class BaseWindow extends TitleWindow
	{
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
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
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
		//  registeredAsPopUp
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _registeredAsPopUp:Boolean = false;
		
		/**
		 * @readonly get registeredAsPopUp
		 * 	Wether this component has been registered as a popup element
		 */ 
		public function get registeredAsPopUp():Boolean
		{
			return _registeredAsPopUp;
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
			
			// set the style
			setStyle("skinClass", Class(BaseWindowSkin));
			
			minWidth  = width;
			minHeight = height; 
			
		}
		
		/**
		 * Toggle
		 */ 
		public function toggle():void
		{
			visible = !visible;
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
		protected function registerAsPopup():void
		{
			try {
				addEventListener(MoveEvent.MOVE, handleMoveEvent);
				PopUpManager.addPopUp(this, parent);
			}
			catch(error:Error) {
				// fail silently
			}
			_registeredAsPopUp = true;
		}
		
		/**
		 * Unregister as popup
		 */ 
		protected function unregisterAsPopup():void
		{
			if (_registeredAsPopUp) {
				try {
					PopUpManager.removePopUp(this);	
				}
				catch (error:Error) {
					// fail silently
				}
			}
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
			invalidateResizeListener();
			registerAsPopup();
		}
		
		/**
		 * Handle removed from stage
		 * 
		 * @param event
		 */ 
		protected function handleRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			unregisterAsPopup();	
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
		 * Handle move event
		 * 
		 * @param event
		 */ 
		protected function handleMoveEvent(event:MoveEvent):void
		{
			if (x < 0) {
				x = 0;
			}
			else if(x > (parent.width - width)) {
				x = parent.width - width;
			}
			
			var parentHeight:Number = parent.height;
			if (y < offsetTop) {
				y = offsetTop;
				trace(stage.width, stage.height);
			}
			else if (y > parent.height - (height + offsetBottom)) {
				y = parent.height - (height + offsetBottom);
				parent.height = parentHeight; // restore parent height
			}
			
			if (!positionFixed || !parent || !parentRectangle) {
				return;
			}
			
			if ((parent.width == parentRectangle.width)  && (parent.height == parentRectangle.height) && !resized) {
				invalidatePositionFixed();
			}
			else if (resized) {
				resized = false;
			}
			
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
			
			root.removeEventListener(MouseEvent.MOUSE_MOVE, handleResizeMouseMove, true);
			root.removeEventListener(MouseEvent.MOUSE_UP, handleResizeMouseUp, true);
			root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleResizeMouseUp);		
		}

	}
}