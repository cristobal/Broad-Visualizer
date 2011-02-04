package elements.transmissions
{

	import core.VariableBase;

	import elements.KeypointBase;


	/**
	 * Variable representing the bitrate
	 */
	public class VariableBitrate extends VariableBase
	{
		
		/**
		 * Name of the variable
		 */
		public override function get name():String { return "Bitrate"; }
		
		
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
			return oldValue + (keypoint as Transmission).size;
		}
	}

}
