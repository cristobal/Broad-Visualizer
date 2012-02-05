package com.bienvisto.view.components
{
	import com.bienvisto.util.HiResStats;

	public final class StatsView extends ViewComponent
	{
		public function StatsView()
		{
			super();
			setup();
		}
		
		/**
		 * @private
		 */ 
		private var stats:HiResStats;
		
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
			
			stats = new HiResStats();
			if (visible) {
				invalidate();
			}
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			if (visible && !contains(stats)) {
				addChild(stats);
			}
			else if (!visible && contains(stats)) {
				removeChild(stats);
			}
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
			
		}
	}
}