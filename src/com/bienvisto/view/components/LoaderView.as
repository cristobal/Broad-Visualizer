package com.bienvisto.view.components
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import spark.components.Image;

	/**
	 * LoaderView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class LoaderView extends ViewComponent
	{
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		// Frames
		[Embed(source="loader/frame_0.gif")]
		private static var Frame0:Class;
		
		[Embed(source="loader/frame_1.gif")]
		private static var Frame1:Class;
		
		[Embed(source="loader/frame_2.gif")]
		private static var Frame2:Class;
		
		[Embed(source="loader/frame_3.gif")]
		private static var Frame3:Class;						
		
		[Embed(source="loader/frame_4.gif")]
		private static var Frame4:Class;
		
		[Embed(source="loader/frame_5.gif")]
		private static var Frame5:Class;
		
		[Embed(source="loader/frame_6.gif")]
		private static var Frame6:Class;	
		
		[Embed(source="loader/frame_7.gif")]
		private static var Frame7:Class;	
		
		/**
		 * @private
		 */ 
		private static var frames:Vector.<Class> = Vector.<Class>([
			Frame0, Frame1, Frame2, Frame3, 
			Frame4, Frame5, Frame6, Frame7
		]);
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function LoaderView()
		{
			super();
			setup();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var timer:Timer;
		
		/**
		 * @private
		 */ 
		private var timerDelay:Number = 90;
		
		/**
		 * @private
		 */ 
		private var frame:int = 0;
		
		/**
		 * @private
		 */ 
		private var image:Image;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			invalidate();
		}
		
		/**
		 * @override
		 */ 
		override public function setSize(width:Number, height:Number):void
		{
			super.width = width;
			super.height = height;
			invalidateSize();	
		}
		
		/**
		 * @override
		 */ 
		override public function set width(value:Number):void
		{
			super.width = width;	
			invalidateSize();
		}
		
		/**
		 * @override
		 */ 
		override public function set height(value:Number):void
		{
			super.height = height;
			invalidateSize();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function invalidateSize():void
		{
			super.invalidateSize();
			image.x = (width + image.width) / 2;
			image.y = (height + image.height) / 2;
			draw();
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			image = new Image();
			addChild(image);
			image.width = 16;
			image.height = 16;
			image.source = frames[frame++];
				
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			if (visible) {
				timer.start();
			}
			else {
				timer.stop();
			}
		}
		
		/**
		 * Draw
		 */ 
		private function draw():void
		{
			graphics.clear();
			graphics.beginFill(0x333333, 0.65);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
		/**
		 * Handle timer
		 * 
		 * @param event
		 */ 
		private function handleTimer(event:TimerEvent):void
		{
			image.source = frames[frame++];
			if (frame >= frames.length) {
				frame = 0;
			}
		}
		
	}
}