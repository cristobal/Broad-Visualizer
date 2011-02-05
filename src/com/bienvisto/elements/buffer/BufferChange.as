package com.bienvisto.elements.buffer
{

	import com.bienvisto.elements.KeypointBase;


	/**
	 * Represents a transmission performed by a node at certain point in the 
	 * simulation
	 * This class will be extended if more info about transmissions is needed
	 */
	public class BufferChange extends KeypointBase
	{
		/**
		 * Number of packets stored in the buffer
		 */
		protected var bufferSize_:uint;
		
		/**
		 * Constructor of the class
		 *
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node performed this transmission
		 * @param node Id of the node associated to this keypoint
		 * @param size Number of packets stored in the buffer
		 */
		public function BufferChange(ms:uint, node:int, size:uint)
		{
			super(ms, node);
			
			bufferSize_ = size;
		}
		
		
		public function get bufferSize():uint { return bufferSize_; }
	}

}
