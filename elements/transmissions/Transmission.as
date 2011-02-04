package elements.transmissions
{

	import elements.KeypointBase;


	/**
	 * Represents a transmission performed by a node at certain point in the 
	 * simulation
	 * This class will be extended if more info about transmissions is needed
	 */
	public class Transmission extends KeypointBase
	{
		/**
		 * Size of the packet transmitted in bytes
		 */
		protected var size_:Number;
		
		/**
		 * Id of the destination node of the received packet
		 */
		protected var destinationNodeId_:int;
		
		
		/**
		 * Constructor of the class
		 *
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node performed this transmission
		 * @param node Id of the node associated to this keypoint
		 * @param size Size of the packet transmitted
		 */
		public function Transmission(ms:uint, node:int, destination:int, size:Number)
		{
			super(ms, node);
			
			size_ = size;
			destinationNodeId_ = destination;
		}
		
		public function get size():Number { return size_; }
		
		public function get destination():int { return destinationNodeId_; }
	}

}
