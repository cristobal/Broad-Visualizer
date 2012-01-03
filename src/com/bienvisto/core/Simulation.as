package com.bienvisto.core
{
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	/**
	 * @public
	 */ 
	[Event(name="timer", type="flash.events.TimerEvent")]

	/**
	 * @public
	 */ 
	[Event(name="timerComplete", type="flash.events.TimerEvent")]
	
	/**
	 * Simulation.as
	 * 
	 * A represenation of the simulation.
	 * Also a trace source parser for the simulation properties from the trace file.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Simulation extends TraceSource
	{
		//--------------------------------------------------------------------------
		//
		// Constants
		//
		//-------------------------------------------------------------------------
		/**
		 * @Event
		 */ 
		[Event(name="ready", type="flash.events.Event")]
		public static const READY:String = "ready";
		
		/**
		 * @Event
		 */ 
		[Event(name="reset", type="flash.events.Event")]
		public static const RESET:String = "reset";
		
		//--------------------------------------------------------------------------
		//
		// Class variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private static var timerDelay:Number = 100;
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Simulation
		 */ 
		public function Simulation()
		{
			super("Simulation", "s");
			setup();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var timer:Timer;
		
		/**
		 * @private
		 */ 
		private var firstRun:Boolean = true;
		
		/**
		 * @private
		 */ 
		private var simulationObjects:Vector.<ISimulationObject>;
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var _speed:Number = 1.0;
		
		/**
		 * @readwrite speed
		 */ 
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set speed(value:Number):void
		{
			_speed = value;
			invalidateSpeed();
		}
		
		/**
		 * @private
		 */ 
		private var _elapsed:Number = 0;
		
		/**
		 * @readonly elapsed
		 */ 
		public function get elapsed():Number
		{
			return _elapsed;
		}
		
		private function setElapsed(value:Number):void
		{
			_elapsed = value;
		}
		
		/**
		 * @private
		 */ 
		private var _duration:uint = 0;
		
		/**
		 * @readonly duration
		 */ 
		public function get duration():uint
		{
			return _duration;
		}
		
		/**
		 * @readonly running
		 */ 
		public function get running():Boolean
		{
			return timer.running;
		}
		
		/**
		 * @private
		 */ 
		private var _time:int = 0;
		
		/**
		 * @reaonly time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		private function setTime(value:uint):void
		{
			_time = value;
		}
		
		/**
		 * Set duration
		 * 
		 * @param value 
		 */ 
		private function setDuration(value:uint):void
		{

			_duration = value;
			invalidate();
		}
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			simulationObjects = new Vector.<ISimulationObject>();

			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			// if this is a new simulation then do a global reset
			if (!firstRun) {
				dispatchEvent(new Event(RESET));
			}		
			
			
			dispatchEvent(new Event(READY));
			firstRun = false;
		}
		
		/**
		 * Invalidate speed
		 */ 
		private function invalidateSpeed():void
		{
			if (timer.running) {
			}
			
			
		}
		
		/**
		 * Add a simulation object
		 * 
		 * @param
		 */
		public function addSimulationObject(item:ISimulationObject):void
		{
			simulationObjects.push(item);
		}
		
		/**
		 * Remove a simulation object
		 * 
		 * @param item
		 */ 
		public function removeSimulationObject(item:ISimulationObject):void
		{
			var value:ISimulationObject;
			for (var i:int = simulationObjects.length; i--;) {
				value = simulationObjects[i];
				if (value == item) {
					simulationObjects.splice(i, 1);
					break;
				}
			}
		}
			
		/**
		 * @private
		 */ 
		private var updateTime:int;
		
		/**
		 * Start
		 */ 
		public function start():void
		{
			if (timer.running) {
				return;
			}
			
			timer.start();
			if (updateTime == 0) {
				updateTime = getTimer();
			}
		}
		
		/**
		 * Pause
		 */ 
		public function pause():void
		{
			timer.stop();
			updateTime = 0;
		}
		
		/**
		 * Jump to
		 * 
		 * @param time
		 */ 
		public function jumpTo(time:uint):void
		{
			
		}
		
		/**
		 * @override
		 */ 
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if ((type == TimerEvent.TIMER) || (type == TimerEvent.TIMER_COMPLETE)) {
				timer.addEventListener(type, listener, useCapture, priority, useWeakReference);	
			}
			else {
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		/**
		 * Update 
		 * 
		 * @param params
		 */ 
		override public function update(params:Vector.<String>):void
		{
			// FORMAT: s <duration> 
			var duration:uint = uint(params[0]);
			setDuration(duration);	
			
		}
		
		/**
		 * Handle timer
		 * 
		 * @param event
		 */ 
		private function handleTimer(event:TimerEvent):void
		{
			var elapsed:int = (getTimer() - updateTime) * speed;
			elapsed = this.time + elapsed;
			var stop:Boolean = false;
			if (elapsed >= duration) {
				timer.stop();
				elapsed = duration;
				stop = true;
			}
			setTime(elapsed);
				
			var simulationObject:ISimulationObject;
			for (var i:int = 0, l:int = simulationObjects.length; i < l; i++) {
				simulationObject = simulationObjects[i];
				simulationObject.onTimeUpdate(elapsed);
			}
			
			if (stop) {
				updateTime = 0;
				dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
			else {
				updateTime = getTimer();
			}
			
		}

	}
}