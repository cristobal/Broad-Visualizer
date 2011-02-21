package com.bienvisto.elements.roles
{
	import com.bienvisto.elements.NodeBase;
	
	/**
	 * Node Role class (immutable)
	 * Holds the information about a node address and role
	 * 
	 */ 
	public class NodeRole extends NodeBase
	{
		
		/**
		 * Constructor
		 */ 
		public function NodeRole(nodeId:int, role:String, address:String)
		{
			super(nodeId);
			
			_role = role;
			_address = address;
		}
		
		
		/**
		 * @private
		 */ 
		private var _role:String;
		
		/**
		 * @readonly role
		 */ 
		public function get role():String
		{
			return _role;
		}
		
		/**
		 * @private
		 */ 
		private var _address:String;
		
		/**
		 * @readonly address
		 */ 
		public function get address():String
		{
			return _address;
		}
		
		/**
		 * @override
		 */ 
		override public function toString():String
		{
			return "{id: " + id + ", role: '" + role + "', address: '" + address + "'}";
		}
	}
}