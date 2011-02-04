package elements.receptions
{

	import elements.KeypointBase;


	/**
	 * Represents a transmission performed by a node at certain point in the 
	 * simulation
	 * This class will be extended if more info about transmissions is needed
	 */
	public class Reception extends KeypointBase
	{
		/**
		 * Size of the packet transmitted in bytes
		 */
		protected var size_:Number;
		
		/**
		 * Id of the source node of the received packet
		 */
		protected var sourceNodeId_:int;
		/**
		 * Id of the real destination of the received packet
		 * (since the received packets are read from the physical layer, it is
		 * possible to get packets for other nodes)
		 */
		protected var destinationNodeId_:int;
		
		
		/**
		 * Constructor of the class
		 *
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node performed this reception
		 * @param node Id of the node associated to this keypoint
		 * @param source Id of the source node of this received packet
		 * @param destination Id of the destination node of this received packet
		 * @param size Size of the packet received
		 */
		public function Reception(ms:uint, node:int, source:int, destination:int, size:Number)
		{
			super(ms, node);
			
			size_ = size;
			destinationNodeId_ = destination;
			sourceNodeId_ = source;
		}
		
		public function get size():Number { return size_; }
		public function get source():int { return sourceNodeId_; }
		public function get destination():int { return destinationNodeId_; }
		
	}

}
