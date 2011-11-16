package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.elements.network.Packet;
	
	/**
	 * Transmission.as
	 * Represents a transmission performed by a node at certain point in the simulation
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class Transmission extends Packet
	{
		public function Transmission(time:uint, id:int, destination:int, size:Number)
		{
			super(time, id, destination, size);
		
		}
	}
}