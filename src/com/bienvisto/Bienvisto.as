package com.bienvisto
{
	import com.bienvisto.core.Simulation;
	import com.bienvisto.core.parser.TraceSourceParser;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.model.WaypointMobilityModel;
	import com.bienvisto.elements.network.Nodes;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.io.FileReferenceReader;
	import com.bienvisto.io.Reader;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	
	import spark.components.Application;

	/**
	 * Bienvisto
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Bienvisto
	{
		public function Bienvisto(app:Application, window:ApplicationWindow)
		{
			setup();
			bindWindow(window);
			
			this.app = app;
			this.window = window;
		}
		
		private var app:Application;
		private var window:ApplicationWindow;
		
		private var simulation:Simulation;
		private var mobilityModel:WaypointMobilityModel;
		private var nodes:Nodes;
		private var mobility:Mobility;
		private var transmissions:Transmissions;
		
		
		private var parser:TraceSourceParser;
		private var reader:FileReferenceReader;

		
		private function setup():void
		{
			simulation 	  = new Simulation();
			simulation.addEventListener(Simulation.READY, handleSimulationReady);
			simulation.addEventListener(Simulation.RESET, handleSimulationReset);
			
			mobilityModel = new WaypointMobilityModel();
			nodes   = new Nodes(mobilityModel);
			mobility = new Mobility(nodes, mobilityModel);
			transmissions = new Transmissions(nodes);
			
			simulation.addSimulationObject(nodes);
			simulation.addSimulationObject(mobility);
			simulation.addSimulationObject(transmissions);
			
			reader = new FileReferenceReader();
			parser = new TraceSourceParser(reader);
			
			parser.addTraceSource(simulation);
			parser.addTraceSource(nodes);
			parser.addTraceSource(mobility);
			parser.addTraceSource(transmissions);
			
			
			
		}
		
		/**
		 * Bind window
		 * 
		 * @param window
		 */ 
		private function bindWindow(window:ApplicationWindow):void
		{
			window.menu.browseFile.addEventListener(MouseEvent.CLICK, handleBrowseFileClick);
		}
		
		/**
		 * Handle simulation ready
		 * 
		 * @param event
		 */ 
		private function handleSimulationReady(event:Event):void
		{
			window.playback.setDuration(
				simulation.duration
			);
		}
		
		/**
		 * Handle simulation reset
		 * 
		 * @param event
		 */ 
		private function handleSimulationReset(event:Event):void
		{
			// Global Reset
		}
		
		
		/**
		 * Handle browse file click
		 * 
		 * @param event
		 */ 
		private function handleBrowseFileClick(event:MouseEvent):void
		{
			reader.browse();
		}
	}
}