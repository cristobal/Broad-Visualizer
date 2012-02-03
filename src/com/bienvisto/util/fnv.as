package com.bienvisto.util
{
	
	/** FNV(Fowler/Noll/Vo) - hash
	 * The core of the FNV-1 hash algorithm is as follows:
	 * 
	 * hash = offset_basis
	 * for each octet_of_data to be hashed
	 * 	hash = hash * FNV_prime
	 * 	hash = hash xor octet_of_data
	 * return hash
	 */
	public function fnv(value:String):String
	{
		var prime:int   = 16777619;   // FNV_prime_32
		var hash:Number = 2166136261; // FNV_offset_basis_32
		var char:String;
		for (var i:int = 0, l:int = value.length; i < l; i++) {
			hash *= prime;
			hash ^= value.charCodeAt(i); 
		}
		
		return String(hash);
	}
	
}