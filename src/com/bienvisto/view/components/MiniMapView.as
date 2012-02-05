package com.bienvisto.view.components
{
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.MobilityArea;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.util.DashedLine;
	import com.bienvisto.util.sprintf;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;

	/**
	 * MiniMapView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class MiniMapView extends ViewComponent
	{
		
		/**
		 * @private
		 */ 
		private static var areaColor:uint = 0x696969;
		
		/**
		 * @private
		 */ 
		private static var clampTime:uint = 2500;
		
		public function MiniMapView(nodeView:NodeView, gridView:GridView, nodeContainer:NodeContainer, mobilityArea:MobilityArea)
		{
			super();
			setup();
			
			
			this.nodeView = nodeView;
			this.gridView = gridView;
			gridView.addEventListener(Event.CHANGE, handleGridViewChange);
			
			this.nodeContainer = nodeContainer;
			this.mobilityArea  = mobilityArea;
			mobilityArea.addEventListener(Event.INIT, handleMobilityAreaInit);
			
		}
		
		/**
		 * @private
		 */ 
		private var nodeView:NodeView;
		
		/**
		 * @private
		 */ 
		private var gridView:GridView;
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var mobility:Mobility;
		
		/**
		 * @private
		 */ 
		private var mobilityArea:MobilityArea;
		
		/**
		 * @private
		 */ 
		private var area:Rectangle;
		
		/**
		 * @private
		 */ 
		private var textField:TextField;
		
		/**
		 * @private
		 */ 
		private var textFormat:TextFormat;
		
		/**
		 * @private
		 */ 
		private var container:Sprite;
		
		/**
		 * @private
		 */ 
		private var lastTime:Number = -1;
		
		
		/**
		 * @private
		 */ 
		private var _displacedRect:Rectangle;
		
		/**
		 * @readonlu displacedRect
		 */ 
		public function get displacedRect():Rectangle
		{
			return _displacedRect;
		}
		
		/**
		 * @override
		 */ 
		override public function set scale(value:Number):void
		{
			// do not scale this view
			super.scale = 1.0;
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			container = new Sprite();
			addChild(container);
			
			
			// draw lines
			var w:int = 300;
			var h:int = 200 - 2;
			
			graphics.lineStyle(2, areaColor);
			graphics.moveTo(0, 0);
			graphics.lineTo(0, h);
			
			graphics.moveTo(w - 1, 0);
			graphics.lineTo(w - 1, h);
			
			graphics.lineStyle(1, areaColor);
			graphics.moveTo(-1, -1);
			graphics.lineTo(4, -1);
			
			graphics.moveTo(-1, h + 1);
			graphics.lineTo(4, h + 1);
			
			graphics.moveTo(w - 5, -1);
			graphics.lineTo(w, -1);
			
			graphics.moveTo(w - 5, h + 1);
			graphics.lineTo(w, h + 1);
			
			// Add text format
			textFormat = new TextFormat("DejaVuSansDF3", 11, areaColor, true);
			textFormat.align = TextAlign.RIGHT;
			
			textField  = new TextField();
			textField.embedFonts = true;
			textField.text = "–";
			textField.setTextFormat(textFormat);
			
			textField.x = 0;
			textField.y = h + 10;
			textField.width = w;
			textField.backgroundColor = 0xFF00FF;
			textField.background = false;
			addChild(textField);
			
			width = w;
			height = h;
			
			x = 20;
			y = 120;
		}	
		

		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			area = mobilityArea.area;
			textField.text = sprintf("Mobility Area = %dx%dm", area.width, area.height);
			textField.setTextFormat(textFormat);
		}
		
		/**
		 * Invalide position
		 */ 
		private function invalidatePosition():void
		{
			
			y = ((gridView.totalVerticalBoxes - 1) * 100) - 300 + 20; // gridView.verticalLineYPos - 300;
		}
		
		/**
		 * @override
		 */ 
		override protected function invalidateScale():void 
		{
			// do not invalidateScale()
		}
		
		/**
		 * @override
		 */ 
		override public function update(time:uint):void
		{
			if (!visible) {
				return;
			}
			
			var elapsed:uint = time - (time % clampTime);
			if (lastTime != elapsed) {
				lastTime  = elapsed;
				
				container.graphics.clear();
				var nodesSprites:Vector.<NodeSprite> = nodeView.nodeSprites;
				var nodeSprite:NodeSprite;
				
				var max_x:Number = 0, max_y:Number = 0;
				var min_x:Number = 0, min_y:Number = 0;
				
				for (var i:int = 0, l:int = nodesSprites.length; i < l; i++) {
					nodeSprite = nodesSprites[i];
					if (nodeSprite.x > max_x) {
						max_x = nodeSprite.x;
					}
					if (nodeSprite.y > max_y) {
						max_y = nodeSprite.y;
					}
					
					if (nodeSprite.x < min_x) {
						min_x = nodeSprite.x;
					}
					if (nodeSprite.y < min_y) {
						min_y = nodeSprite.y;
					}
				}
				
				
				var aw:Number = Math.abs(max_x - min_x);
				var ah:Number = Math.abs(max_y - min_y);
				if (area) {
					aw += area.width / 8;
					ah += area.height / 8;
				}
				
				var tw:Number = 250;
				var th:Number = 150;
				var ow:Number = 25;
				var oy:Number = 25;
				
				var radius:Number = 2.5;
				var offset:Number = radius;
				for (i = 0; i < l; i++) {
					nodeSprite = nodesSprites[i];
					
					var nx:Number = nodeSprite.x + (nodeSprite.radius / 2);
					var ny:Number = nodeSprite.y + (nodeSprite.radius / 2);
					
					var tx:Number = (nx / aw) * tw;
					var ty:Number = (ny / ah) * th;
					
					if ((tx - offset) < 0 || (tx + offset) > tw || (ty - offset) < 0 || (ty + offset) > th) {
						continue;
					}
					
					container.graphics.beginFill(areaColor);
					container.graphics.drawCircle(tx + ow, ty + oy, radius);
					container.graphics.endFill();
					
				}
				_displacedRect = new Rectangle(0, 0, aw, ah);
			}
		}
		
		
		/**
		 * Handle grid view change
		 * 
		 * @param event
		 */ 
		private function handleGridViewChange(event:Event):void
		{
			invalidatePosition();
		}
		
		/**
		 * Handle mobility area init
		 * 
		 * @param event
		 */ 
		private function handleMobilityAreaInit(event:Event):void
		{
			invalidate();
		}
		
	}
}