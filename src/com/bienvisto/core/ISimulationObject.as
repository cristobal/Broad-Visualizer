package com.bienvisto.core
{
	/**
	 * ISimulationObject.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public interface ISimulationObject
	{
		function onTimeUpdate(elapsed:uint):void;
		function setDuration(duration:uint):void;
	}
}