/* 
DashedLine class
Refactored 05/11/2010 by Sebastian Herrlinger <sebastian@formzoo.com> (http://sebastian.formzoo.com)
Original work by Andy Woodruff (http://cartogrammar.com/blog || awoodruff@gmail.com)
May 2008

Example:
var shape:Shape = new Shape();
shape.graphics.lineStyle(2, 0x00ff00);
DashedLine.moveTo(shape.graphics, 120,120);
DashedLine.lineTo(shape.graphics, 220,120);
DashedLine.lineTo(shape.graphics, 220,220);
DashedLine.lineTo(shape.graphics, 120,220);
DashedLine.lineTo(shape.graphics, 120,120);
*/
package com.broad.util
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class DashedLine {
		
		private static var lengthsArray:Array = [5, 5];	// array of dash and gap lengths (dash,gap,dash,gap....)
		private static var curX:Number = 0;	
		private static var curY:Number = 0;	
		private static var remainingDist:Number = 0;	
		private static var curLengthIndex:int = 0;
		private static var lengthStartIndex:int = 0;
		
		public static function setDashes(dashes:Array):void
		{
			lengthsArray = dashes;
			lengthStartIndex = 0;
		}
		
		public static function moveTo(g:Graphics, x:Number,y:Number):void{
			g.moveTo(x, y);
			curX = x;	
			curY = y;
			remainingDist = 0;
			lengthStartIndex = 0;
		}
		
		public static function lineTo(g:Graphics, x:Number,y:Number):void{
			var slope:Number = (y - curY)/(x - curX);
			var startX:Number = curX;
			var startY:Number = curY;
			var xDir:int = (x < startX) ? -1 : 1;
			var yDir:int = (y < startY) ? -1 : 1;
			
			// keep drawing dashes and gaps as long as either the current x or y is not beyond the destination x or y
			outerLoop : while (Math.abs(startX - curX) < Math.abs(startX - x) || Math.abs(startY - curY) < Math.abs(startY - y))
			{
				for (var i:int = lengthStartIndex; i < lengthsArray.length; i++)
				{
					var dist:Number = (remainingDist == 0) ? lengthsArray[i] : remainingDist;
					var xInc:Number = getCoords(dist, slope).x * xDir;
					var yInc:Number = getCoords(dist, slope).y * yDir;
					
					if (Math.abs(startX - curX) + Math.abs(xInc) < Math.abs(startX - x) 
						|| Math.abs(startY - curY) + Math.abs(yInc) < Math.abs(startY - y))
					{
						if (i % 2 == 0)
						{
							g.lineTo(curX + xInc, curY + yInc);
						} else {
							g.moveTo(curX + xInc, curY + yInc);
						}
						curX += xInc;
						curY += yInc;
						curLengthIndex = i;
						lengthStartIndex = 0;
						remainingDist = 0;
					} else {
						remainingDist = getDistance(curX, curY, x, y);
						curLengthIndex = i;
						break outerLoop;
					}
				}
			}
			
			lengthStartIndex = curLengthIndex;
			
			if (remainingDist != 0)
			{
				if (curLengthIndex % 2 == 0)
					g.lineTo(x,y);
				else
					g.moveTo(x,y);
				remainingDist = lengthsArray[curLengthIndex] - remainingDist;
			} else {
				if (lengthStartIndex == lengthsArray.length - 1)
					lengthStartIndex = 0;
				else
					lengthStartIndex++;
			}
			curX = x;
			curY = y;
		}
		
		private static function getCoords(distance:Number, slope:Number):Point 
		{
			var angle:Number = Math.atan(slope);
			var vertical:Number = Math.abs(Math.sin(angle) * distance);
			var horizontal:Number = Math.abs(Math.cos(angle) * distance);
			return new Point(horizontal, vertical);
		}
		
		private static function getDistance(startX:Number, startY:Number, endX:Number, endY:Number):Number
		{
			var distance:Number = Math.sqrt(Math.pow((endX - startX),2) + Math.pow((endY - startY), 2));
			return distance;
		}
	}
}