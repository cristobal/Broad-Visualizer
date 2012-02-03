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
			_recv      = new SequencesRecv(this);
			_sent      = new SequencesSent(this);
			_inserted  = new SequencesInserted(this);
			_forwarded = new SequencesForwarded(this);
			
			_nodeContainer  = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var _nodeContainer:NodeContainer;
		
		/**
		 * @readonly nodeContainer 
		 */ 
		public function get nodeContainer():NodeContainer
		{
			return _nodeContainer;
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