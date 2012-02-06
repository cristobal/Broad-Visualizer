package com.bienvisto.ui.windows.charts
{
	import com.bienvisto.ui.windows.BaseWindow;
	
	/**
	 * ChartsWindowContainer.as
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class ChartsWindowContainer extends BaseWindow
	{
		/**
		 * @private
		 */ 
		private static var nextOID:int = 1;
		
		/**
		 * Constructor
		 */ 
		public function ChartsWindowContainer()
		{
			super();
		}
		
		/**
		 * @private
		 */ 
		private var _oid:int = -1;
		
		/**
		 * @readonly oid
		 */ 
		public function get oid():int
		{
			if (_oid < 0) {
				_oid = nextOID++;
			}
			return _oid;
		}
		
		/**
		 * @override
		 */ 
		override protected function setup():void
		{
			super.setup();
			title = "Charts - #" + String(oid);
		}
		
	}
}