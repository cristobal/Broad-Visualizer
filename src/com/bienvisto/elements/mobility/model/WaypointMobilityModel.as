package com.bienvisto.elements.mobility.model
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.elements.mobility.IMobilityModel;
	import com.bienvisto.elements.mobility.Waypoint;
	import com.bienvisto.elements.mobility.Waypoint2D;

	public class WaypointMobilityModel implements IMobilityModel
	{
		public function WaypointMobilityModel()
		{
		}
		
		public function get name():String
		{
			return "Waypoint";
		}
		
		public function getWaypoint(params:Vector.<String>):Waypoint
		{
			// FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>
			// var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var pos:Vector2D = new Vector2D(Number(params[2]), Number(params[3]));
			var dir:Vector2D = new Vector2D(Number(params[4]), Number(params[5]));
			
			var point:Waypoint2D = new Waypoint2D(time, pos, dir);
			
			return point;
		}
	}
}