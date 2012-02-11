package com.gran.ui.menus
{
	/**
	 * IntervalStepper.as
	 * 
	 * @author Cristobal Dabed
	 */ 	
	public final class IntervalStepper extends MenuStepper
	{
		public function IntervalStepper()
		{
			super();
		}
		
		/**
		 * @override
		 */ 
		override public function get value():Number
		{
			var val:Number = super.value;
			if (isNaN(val)) {
				val = lastValue;
			}
			
			return val;
		}
		
		/**
		 * @override
		 */ 
		override public function changeValueByStep(increase:Boolean=true):void
		{
			if (value == 1 && increase) {
				minimum		 = 1;
				maximum		 = 10;
				stepSize 	 = 0.50;
				snapInterval = 0.50;
			}
			
			var result:Number;
			if (increase) {
				if ((value < 1.0)  && (value + stepSize > 1.0)) {
					value = 1;
				}
				if ((value > 1.0)  && (value + stepSize > maximum)) {
					value = maximum;
				}
				else {
					value += stepSize;
				}
			}
			else {
				if(value == 1.0) {
					minimum		 = 0.1;
					maximum		 = 1;
					stepSize 	 = 0.25;
					snapInterval = 0.25;
				}
				if ((value < 1.0)  && (value - stepSize < 0.1)) {
					value = 0.1;
				}
				else {
					value -= stepSize;
				}
			}
			// super.changeValueByStep(increase);
		}

	}
}