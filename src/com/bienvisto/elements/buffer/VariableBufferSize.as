package com.bienvisto.elements.buffer
{
	import flash.utils.getTimer;

	import mx.collections.ArrayList;

	import com.bienvisto.core.VariableBase;
	import com.bienvisto.core.Tools;

	import com.bienvisto.elements.KeypointBase;


	/**
	 * Variable representing the bitrate
	 */
	public class VariableBufferSize extends VariableBase
	{
		
		/**
		 * Name of the variable
		 */
		public override function get name():String { return "Packets in buffer"; }
		
		
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
			// We calculate the average of the group when adding the new keypoint
			return (oldValue*groupSize + (keypoint as BufferChange).bufferSize)
				/ (groupSize + 1);
		}
		
	}

}
