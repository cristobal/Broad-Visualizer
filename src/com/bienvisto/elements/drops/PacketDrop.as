package com.bienvisto.elements.drops
{

	import com.bienvisto.elements.KeypointBase;


	/**
	 * Represents a transmission performed by a node at certain point in the 
	 * simulation
	 * This class will be extended if more info about transmissions is needed
	 */
	public class PacketDrop extends KeypointBase
	{
		
		
		/**
		 * Constructor of the class
		 *
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node performed this transmission
		 * @param node Id of the node associated to this keypoint
		 */
		public function PacketDrop(ms:uint, node:int)
		{
			super(ms, node);
		}
		
	}

}
