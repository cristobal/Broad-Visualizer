package com.bienvisto.elements.mobility
{
	public interface IMobilityModel
	{
		function get name():String;
		function getWaypoint(params:Vector.<String>):Waypoint;
	}
}