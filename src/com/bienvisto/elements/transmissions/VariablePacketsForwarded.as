package com.bienvisto.elements.transmissions
{

	import com.bienvisto.core.VariableBase;

	import com.bienvisto.elements.KeypointBase;


	/**
	 * Variable representing the packets forwarded through time
	 */
	public class VariablePacketsForwarded extends VariableBase
	{
		
		/**
		 * Name of the variable
		 */
		public override function get name():String { return "Packets Forwarded"; }
		
		
		public override function get minimumResolution():Number
		{
			return 1000.0;
		}
		public override function get maximumResolution():Number
		{
			return 10000.0;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function aggregateKeypoint(oldValue:Number, groupSize:int,
			keypoint:KeypointBase):Number
		{
			// We add one packet forwarded
			return oldValue+1;
		}
	}

}
