package com.broad.util
{
	public final class OIDUtil
	{
		/**
		 * @private
		 */ 
		private static var oid:Number = 0;
		
		public static function getNext():Number
		{
			return oid++;
		}
		
		
	}
}