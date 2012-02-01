package com.bienvisto.elements.sequences
{
	import com.bienvisto.elements.network.node.NodeContainer;

	/**
	 * SequencesContainer.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesContainer
	{
		public function SequencesContainer(nodeContainer:NodeContainer)
		{
			_destinations = new SequencesDestinations(nodeContainer);
			_sources	  = new SequencesSources(nodeContainer);
			
			_recv = new SequencesRecv(nodeContainer);
			_sent = new SequencesSent(nodeContainer);
			_inserted = new SequencesInserted(nodeContainer);
			_forwarded = new SequencesForwarded(nodeContainer);
		}
		
		/**
		 * @private
		 */ 
		private var _destinations:SequencesDestinations;
		
		/**
		 * @readonly destinations
		 */ 
		public function get destinations():SequencesDestinations
		{
			return _destinations;
		}
		
		/**
		 * @private
		 */ 
		private var _sources:SequencesSources;
		
		/**
		 * @readonly sources
		 */ 
		public function get sources():SequencesSources
		{
			return _sources;
		}
		
		/**
		 * @private
		 */ 
		private var _recv:SequencesRecv;
		
		/**
		 * @readonly recv
		 */ 
		public function get recv():SequencesRecv
		{
			return _recv;	
		}
		
		/**
		 * @private
		 */ 
		private var _sent:SequencesSent;
		
		/**
		 * @readonly sent
		 */ 
		public function get sent():SequencesSent
		{
			return _sent;
		}
		
		/**
		 * @private
		 */ 
		private var _inserted:SequencesInserted;
		
		/**
		 * @readonly inserted
		 */ 
		public function get inserted():SequencesInserted
		{
			return _inserted;
		}
		
		/**
		 * @private
		 */ 
		private var _forwarded:SequencesForwarded;
		
		/**
		 * @readonly forwarded
		 */ 
		public function get forwarded():SequencesForwarded
		{
			return _forwarded;
		}
		
	}
}