package core
{
	import flash.display.Graphics;
	
	import mx.core.FlexGlobals;
	
	
	/**
	 * A set of static functions useful in several points of the Visualizer
	 */
	public class Tools
	{
		public static const LOG_LEVEL_NOTE:String = "logLevelWarning";
		public static const LOG_LEVEL_WARNING:String = "logLevelWarning";
		public static const LOG_LEVEL_ERROR:String = "logLevelWarning";
		
		
		/**
		 * Adds some text to the visualizer log
		 *
		 * @param	text	Text to log
		 * @param	level	Level of this log line (LOG_LEVEL_NOTE, LOG_LEVEL_ERROR, LOG_LEVEL_WARNING)
		 *
		 */
		public static function log(text:String, level:String = Tools.LOG_LEVEL_NOTE):void
		{
			FlexGlobals.topLevelApplication.logTextBox.text += text + "\n";
		}


		/**
		 * Draws a vectorial arrow from origin to end in graphics, using the
		 * specified color
		 */
		public static function drawArrow(origin:Vector2D, end:Vector2D, graphics:Graphics, color:uint, thickness:uint = 1):void
		{
			if (origin != null && end != null)
			{
				var angle:Number = Math.atan2(end.y-origin.y, end.x-origin.x);
				var spread:Number = .5;
				var size:Number = 20;
				end.x -= 10*Math.cos(angle);
				end.y -= 10*Math.sin(angle);
				
				graphics.lineStyle(thickness, color);
				graphics.moveTo(origin.x, origin.y);
				graphics.lineTo(end.x, end.y);
				graphics.lineTo(end.x-Math.cos(angle+spread)*size, end.y-Math.sin(angle+spread)*size);
				graphics.moveTo(end.x-Math.cos(angle-spread)*size, end.y-Math.sin(angle-spread)*size);
				graphics.lineTo(end.x, end.y);
			}
		}


		/**
		 * Formats a certain time in milliseconds to a hours:minutes:seconds
		 * format.
		 *
		 * @param ms A time value in milliseconds
		 *
		 * @return Time in hours:minutes:seconds format
		 *
		 * @example <code>Tools.millisecondsToText(30000)</code> will return
		 * 00:00:30
		 */
		public static function millisecondsToText(ms:uint):String
		{
			var hours:int = Math.floor(ms / (1000 * 60 * 60));
			ms -= hours * (1000 * 60 * 60);
			var minutes:int = Math.floor(ms / (1000 * 60)) % 60;
			ms -= minutes * (1000 * 60);
			var seconds:int = Math.floor(ms / 1000);
	
			return (hours < 10 ? "0" : "") + hours + ":"
				+ (minutes < 10 ? "0" : "") +  minutes + ":"
				+ (seconds < 10 ? "0" : "") + seconds;
		}


		/**
		 * Returns certain amout of milliseconds to an approximate, short
		 * string.
		 *
		 * @param ms A time value in milliseconds
		 *
		 * @return Time in short form
		 *
		 * @exampe <code>Tools.msToShortString(30000)</code> will return
		 * 30s
		 */
		public static function msToShortString(ms:uint):String
		{
			if (ms < 1000)
				return ms.toString() + "ms";
			
			var hours:int = Math.floor(ms / (1000 * 60 * 60));
			var minutes:int = Math.floor(ms / (1000 * 60));
			var seconds:int = Math.floor(ms / 1000);
			
			if (seconds < 120)
				return seconds.toString() + "s";
			if (minutes < 120)
				return minutes.toString() + "m";
			
			return hours.toString() + "h";
		}

		/**
		 * Lightens a given color
		 *
		 * @param color Color to lighten
		 * @param amount How much it will be lightened
		 */
		public static function lightenColor(color:uint, amount:Number):Number
		{
			var rgb:Object = hexToRGB(color);
			for (var element:Object in rgb)
			{
				rgb[element] += (255 - rgb[element]) * amount;
			}
			
			return rgbToHex(rgb.r, rgb.g, rgb.b);
		}

		/**
		 * Darkens a given color
		 *
		 * @param color Color to darken
		 * @param amount How much it will be darkened
		 */
		public static function darkenColor(color:uint, amount:Number):Number
		{
			var rgb:Object = hexToRGB(color);
			for (var element:Object in rgb)
			{
				rgb[element] = rgb[element] * (1-amount);
			}
			
			return (rgbToHex(rgb.r, rgb.g, rgb.b));
		}

		/**
		 * Returns the hexadecimal representation of a color, given its RGB
		 * channels
		 */
		public static function rgbToHex(r:Number, g:Number, b:Number):Number
		{
			var rgb:String = "0x" + (r<16?"0":"") + r.toString(16) + (g<16?"0":"") + g.toString(16) + (b<16?"0":"") + b.toString(16);
			return Number(rgb);
		}


		/**
		 * Returns and object containing the RGB channels of a given color in
		 * hexadecimal notation
		 */
		public static function hexToRGB(color:uint):Object
		{
			var r:int = color >> 16 & 0xFF;
			var g:int = color >> 8 & 0xFF;
			var b:int = color & 0xFF;
			return {r:r, g:g, b:b};
		}


	}
}
