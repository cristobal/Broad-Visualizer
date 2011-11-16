package com.bienvisto.util
{
	/**
	 * Mutex.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Mutex
	{
		public function Mutex()
		{
		}
		
		private var _locked:Boolean = false;
		
		/**
		 * @readonly locked
		 */ 
		public function get locked():Boolean 
		{
			return _locked;
		}
		
		/**
		 * lock
		 */ 
		public function lock():void
		{
			_locked = true;
		}
		
		/**
		 * unlock
		 */ 
		public function unlock():void
		{
			_locked = false;
		}
	}
}