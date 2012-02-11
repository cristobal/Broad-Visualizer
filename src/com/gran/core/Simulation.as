package com.gran.core
{
	import com.gran.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	
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
	 * A representation of the simulation.
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
		 * 	Distpatched when the simulation is ready
		 */ 
		[Event(name="ready", type="flash.events.Event")]
		public static const READY:String = "ready";
		
		/**
		 * @Event
		 * 	Dispatched 
		 */
		[Event(name="complete", type="flash.events.Event")]
		public static const COMPLETE:String = "complete";
		
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
		private var _internalTime:uint = 0;
		
		/**
		 * @readonly internalTime
		 */ 
		public function get internalTime():uint
		{
			return _internalTime;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint = 0;
		
		
		/**
		 * @reaonly time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		private function setTime(value:uint):void
		{
			_time = value - (value % 100); // fix to 100th of a second 
			_internalTime = value;
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
		
		/**
		 * @priavte
		 */ 
		private var _loaded:Number = 0;
		
		/**
		 * @readwrite loaded
		 */ 
		public function get loaded():Number
		{
			return _loaded;
		}
		
		public function setLoaded(value:Number):void
		{
			value = int(value);
			if (value > _loaded) {	
				if (value < 0) {
					value = 0;
				}
				else if (value > 100) {
					value = 100;
				}
				
				_loaded = value;
			}
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
			// If not first run do a global reset
			if (!firstRun) {
				reset();
			}
			
			for (var i:int = simulationObjects.length; i--; ) {
				simulationObjects[i].setDuration(duration);
			}	
			setTimeout(notifyReady, 10);
		}
		
		/**
		 * Reset
		 */ 
		private function reset():void
		{
			if (running) {
				pause();
			}
			jumpToTime(0);
			for (var i:int = simulationObjects.length; i--;) {
				simulationObjects[i].reset();
			}
			
			dispatchEvent(new Event(RESET));
			gc(); // Call system gc
		}
		
		/**
		 * Notify ready
		 */ 
		private function notifyReady():void
		{
			dispatchEvent(new Event(READY));
			firstRun = false;
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
		private var updateTime:int = 0;
		
		/**
		 * Start
		 */ 
		public function start():void
		{
			if (timer.running) {
				return;
			}
			
			if (time == duration) {
				setTime(0); // reset time
				updateTime = 0;
			}
			
			if (updateTime == 0) {
				updateTime = getTimer();
			}
			
			timer.start();
		}
		
		/**
		 * Pause
		 */ 
		public function pause():void
		{
			if (timer.running) {
				timer.stop();
			}
		
			updateTime = 0;
		}
		
		/**
		 * Jump to
		 * 
		 * @param time
		 */ 
		public function jumpToTime(time:uint):void
		{
			var total:Number = (time / duration) * 100;
			var flag:Boolean = false;
			if (total > loaded) {
				flag = true;
			}
			setTime(time);
			if (timer.running) {
				updateTime = getTimer();
			}
			else {
				updateTime = 0;
			}
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
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: s <duration> 
			var duration:uint = uint(params[0]);
			setDuration(duration);	
			
			return time;	
		}
		
		/**
		 * Handle timer
		 * 
		 * @param event
		 */ 
		private function handleTimer(event:TimerEvent):void
		{
			var elapsed:int = (getTimer() - updateTime) * speed;
			
			elapsed = internalTime + elapsed;
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
				dispatchEvent(new Event(COMPLETE));
				setTimeout(gc, 10);
			}
			else {
				updateTime = getTimer();
			}
			
		}
		
		/**
		 * Request for gc
		 */ 
		private function gc():void
		{
			System.gc(); // Garbage collect at this point
		}

	}
}