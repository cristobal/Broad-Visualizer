package com.bienvisto
{
	import com.bienvisto.core.Simulation;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.network.graph.AdjacencyMatrix;
	import com.bienvisto.core.network.graph.Graph;
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.core.parser.TraceSourceParser;
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.elements.buffer.BuffersDataProvider;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.drops.DropsDataProvider;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.MobilityArea;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.receptions.ReceptionsDataProvider;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.elements.routing.SimpleRoute;
	import com.bienvisto.elements.sequences.SequencesContainer;
	import com.bienvisto.elements.sequences.providers.SequencesForwardedDataProvider;
	import com.bienvisto.elements.sequences.providers.SequencesInsertedDataProvider;
	import com.bienvisto.elements.sequences.providers.SequencesRecvDataProvider;
	import com.bienvisto.elements.sequences.providers.SequencesSentDataProvider;
	import com.bienvisto.elements.sequences.sources.SequencesForwarded;
	import com.bienvisto.elements.sequences.sources.SequencesRecv;
	import com.bienvisto.elements.sequences.sources.SequencesSent;
	import com.bienvisto.elements.topology.Topology;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.elements.transmissions.TransmissionsBitrateDataProvider;
	import com.bienvisto.elements.transmissions.TransmissionsDataProvider;
	import com.bienvisto.io.FileReferenceReader;
	import com.bienvisto.io.Reader;
	import com.bienvisto.ui.menus.Playback;
	import com.bienvisto.ui.menus.PlaybackContainer;
	import com.bienvisto.ui.menus.ProgressTimeSlider;
	import com.bienvisto.view.VisualizerView;
	import com.bienvisto.view.components.GridView;
	import com.bienvisto.view.components.LoaderView;
	import com.bienvisto.view.components.MiniMapView;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.components.PerimeterView;
	import com.bienvisto.view.components.StatsView;
	import com.bienvisto.view.drawing.NodeBuffersDrawingManager;
	import com.bienvisto.view.drawing.NodeDrawingManager;
	import com.bienvisto.view.drawing.NodeDropsDrawingManager;
	import com.bienvisto.view.drawing.NodeIDDrawingManager;
	import com.bienvisto.view.drawing.NodeMobilityDrawingManager;
	import com.bienvisto.view.drawing.NodeReceptionsDrawingManager;
	import com.bienvisto.view.drawing.NodeRoutingDrawingManager;
	import com.bienvisto.view.drawing.NodeTransmissionsDrawingManager;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import spark.components.Application;

	/**
	 * Bienvisto
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Bienvisto
	{
		/**
		 * Constructor
		 * 
		 * @param app
		 * @param window
		 */ 
		public function Bienvisto(app:Application, window:ApplicationWindow)
		{		
			setup(window);
			bindWindow(window);
			
			this.app 	= app;
			// this.app.frameRate = 30; // 30fps
			this.window = window; 
		}
		
		private var app:Application;
		private var window:ApplicationWindow;
		
		/* -- trace sources and simulation objects -- */
		private var simulation:Simulation;
		private var nodeContainer:NodeContainer;
		private var mobility:Mobility;
		private var mobilityArea:MobilityArea;
		private var transmissions:Transmissions;
		private var receptions:Receptions;
		private var drops:Drops;
		private var buffers:Buffers;
		private var routing:Routing;
		private var topology:Topology;
		private var sequencesContainer:SequencesContainer;
		
		/* -- parsed + reader -- */
		private var parser:TraceSourceParser;
		private var reader:FileReferenceReader;
	
		/* -- visualiser view & its view components-- */
		private var view:VisualizerView;
		private var nodeView:NodeView;
		private var gridView:GridView;
		private var statsView:StatsView;
		private var miniMapView:MiniMapView;
		private var perimeterView:PerimeterView;
		private var loaderView:LoaderView;
		
		/* -- Node view drawing managers -- */
		private var nodeIDDrawingManager:NodeDrawingManager;
		private var mobilityDrawingManager:NodeMobilityDrawingManager;
		private var transmissionsDrawingManager:NodeTransmissionsDrawingManager;
		private var receptionsDrawingManager:NodeReceptionsDrawingManager;
		private var dropsDrawingManager:NodeDropsDrawingManager;
		private var routingDrawingManager:NodeRoutingDrawingManager;
		private var buffersDrawingManager:NodeBuffersDrawingManager;
		
		/**
		 * Setup
		 */ 
		private function setup(window:ApplicationWindow):void
		{
			// Setup simulation
			simulation 	  = new Simulation();
			simulation.addEventListener(Simulation.READY, handleSimulationReady);
			simulation.addEventListener(Simulation.RESET, handleSimulationReset);
			simulation.addEventListener(Simulation.COMPLETE, handleSimulationComplete);
			simulation.addEventListener(TimerEvent.TIMER, handleSimulationTimer);
			
			// Setup simulation objects
			nodeContainer = new NodeContainer();
			
			mobility 	  = new Mobility(nodeContainer);
			mobilityArea  = new MobilityArea();
			
			transmissions = new Transmissions(nodeContainer);
			receptions	  = new Receptions(nodeContainer);
			drops		  = new Drops(nodeContainer);
			buffers		  = new Buffers(nodeContainer);
			
			routing		    = new Routing(nodeContainer);
			topology		= new Topology(nodeContainer);
			
			sequencesContainer = new SequencesContainer(nodeContainer);

			// Listen to simulation object first change
			mobilityArea.addEventListener(Event.INIT, handleMobilityAreaInit);
			routing.addEventListener(Event.INIT, handleRoutingInit);
			topology.addEventListener(Event.INIT, handleTopologyInit);
			sequencesContainer.sent.addEventListener(Event.INIT, handleSequencesInit);
			
			// Add simulation objects			
			simulation.addSimulationObject(nodeContainer);
			simulation.addSimulationObject(mobility);
			simulation.addSimulationObject(mobilityArea);
			simulation.addSimulationObject(transmissions);
			simulation.addSimulationObject(receptions);
			simulation.addSimulationObject(drops);
			simulation.addSimulationObject(buffers);
			simulation.addSimulationObject(routing);
			simulation.addSimulationObject(topology);			
			simulation.addSimulationObject(sequencesContainer.sent);
			simulation.addSimulationObject(sequencesContainer.recv);
			simulation.addSimulationObject(sequencesContainer.inserted);
			simulation.addSimulationObject(sequencesContainer.forwarded);
			
			// Reader Part
			reader = new FileReferenceReader();
			parser = new TraceSourceParser(reader);
			
			// Add trace sources
			parser.addTraceSource(simulation);
			parser.addTraceSource(mobilityArea);
			parser.addTraceSource(nodeContainer);
			parser.addTraceSource(mobility);
			parser.addTraceSource(transmissions);
			parser.addTraceSource(receptions);
			parser.addTraceSource(drops);
			parser.addTraceSource(buffers);
			parser.addTraceSource(routing);
			parser.addTraceSource(topology);
			parser.addTraceSource(sequencesContainer.sent);
			parser.addTraceSource(sequencesContainer.recv);
			parser.addTraceSource(sequencesContainer.inserted);
			parser.addTraceSource(sequencesContainer.forwarded);;
			
			parser.addEventListener(TimedEvent.ELAPSED, handleParserTimedEventElapsed);
			parser.addEventListener(Event.COMPLETE, handleParserEventComplete);
			
			// Setup the view
			// 1. Append nodes
			view = window.visualizerView;
			
			// 2. Add views
			gridView = new GridView();
			view.addViewComponent(gridView);
			
			nodeView = new NodeView(nodeContainer)
			view.addViewComponent(nodeView);
			view.setDraggableView(nodeView);
			
			statsView = new StatsView();
			view.addViewComponent(statsView);
			
			miniMapView = new MiniMapView(nodeView, gridView, nodeContainer, mobilityArea);
			view.addViewComponent(miniMapView);
			view.setMiniMapView(miniMapView);
			
			perimeterView = new PerimeterView(nodeView, mobilityArea);
			
			loaderView = new LoaderView();
			view.setLoaderView(loaderView);
			
			
			// 3 Append node drawing managers
			nodeIDDrawingManager = new NodeIDDrawingManager();
			nodeView.addDrawingManager(nodeIDDrawingManager);
			
			mobilityDrawingManager = new NodeMobilityDrawingManager(mobility);
			nodeView.addDrawingManager(mobilityDrawingManager);
			
			receptionsDrawingManager = new NodeReceptionsDrawingManager(receptions);
			nodeView.addDrawingManager(receptionsDrawingManager);
			
			transmissionsDrawingManager = new NodeTransmissionsDrawingManager(transmissions, nodeView);
			nodeView.addDrawingManager(transmissionsDrawingManager);
			
			dropsDrawingManager = new NodeDropsDrawingManager(drops);
			nodeView.addDrawingManager(dropsDrawingManager);
			
			buffersDrawingManager = new NodeBuffersDrawingManager(buffers);
			nodeView.addDrawingManager(buffersDrawingManager);
			
			routingDrawingManager = new NodeRoutingDrawingManager(routing, nodeView);
			nodeView.addDrawingManager(routingDrawingManager);
			
		}
		
		/**
		 * Bind window
		 * 
		 * @param window
		 */ 
		private function bindWindow(window:ApplicationWindow):void
		{	
			/* -- Menu-- */
			// window menu add toggeable node drawing managers
			window.menu.addToggeableNodeDrawingManager(nodeIDDrawingManager);
			window.menu.addToggeableNodeDrawingManager(buffersDrawingManager);
			window.menu.addToggeableNodeDrawingManager(transmissionsDrawingManager);
			window.menu.addToggeableNodeDrawingManager(receptionsDrawingManager);
			window.menu.addToggeableNodeDrawingManager(dropsDrawingManager);
			window.menu.addToggeableNodeDrawingManager(routingDrawingManager);
			window.menu.addToggeableNodeDrawingManager(routingDrawingManager.selectedDrawingManager);
			window.menu.addToggeableNodeDrawingManager(routingDrawingManager.betweenNodesDrawingManager);
			
			window.menu.browseFileButton.addEventListener(MouseEvent.CLICK, handleBrowseFileClick);
			
			
			/* -- Playback-- */
			// window playback set misc view components
			window.playback.addZoomView(gridView);
			window.playback.addZoomView(nodeView);
			window.playback.setGridView(gridView);
			window.playback.setStatsView(statsView);
			window.playback.setMiniMapView(miniMapView);
			window.playback.setPerimeterView(perimeterView);
			
			window.playback.menu.enabled = false;
			window.playback.playbackSpeed.addEventListener(Event.CHANGE, handlePlaybackSpeedChange);
			window.playback.addEventListener(Playback.PLAY, handlePlayButtonStateChange);
			window.playback.addEventListener(Playback.PAUSE, handlePlayButtonStateChange);
			
			window.playback.addEventListener(TimedEvent.ELAPSED, handlePlaybackProgressTimerElapsed);
			window.playback.addEventListener(ProgressTimeSlider.CHANGE_START, handlePlaybackProgressTimerChangeStart);
			window.playback.addEventListener(ProgressTimeSlider.CHANGE_END, handlePlaybackProgressTimerChangeEnd);
			window.playback.addEventListener(ProgressTimeSlider.LOAD_START, handlePlaybackProgressTimerLoadStart);
			window.playback.addEventListener(ProgressTimeSlider.LOAD_END, handlePlaybackProgressTimerLoadEnd);
			
			
			/* -- Node Windows -- */
			// window nodeWindows set the trace source components
			window.nodeWindows.setMobility(mobility);
			window.nodeWindows.setRouting(routing);
			window.nodeWindows.setTopology(topology);
			window.nodeWindows.setBuffers(buffers);
			window.nodeWindows.setTransmissions(transmissions);
			window.nodeWindows.setReceptions(receptions);
			window.nodeWindows.setDrops(drops);
			window.nodeWindows.setSequencesContainer(sequencesContainer);
			
			// window nodeWindows set the node view
			window.nodeWindows.setNodeView(nodeView);
			
			
			/* -- Topology -- */
			// Window topology window set nodeContainer + routing
			window.topologyWindows.setNodeContainer(nodeContainer);
			window.topologyWindows.setRouting(routing);
			window.topologyWindows.setTopology(topology);
			window.topologyWindows.setNodeView(nodeView);
			
			
			/* -- Charts -- */
			// Assign the nodeContainer for the charts
			window.chartsWindows.setNodeContainer(nodeContainer);
			
			// Append data providers for the charts windows
			window.chartsWindows.addDataProvider(
				new BuffersDataProvider(buffers)
			);
			window.chartsWindows.addDataProvider(
				new DropsDataProvider(drops)
			);
			window.chartsWindows.addDataProvider(
				new ReceptionsDataProvider(receptions)
			);
			window.chartsWindows.addDataProvider(
				new TransmissionsDataProvider(transmissions)
			);
			window.chartsWindows.addDataProvider(
				new TransmissionsBitrateDataProvider(transmissions)
			);
			window.chartsWindows.addDataProvider(
				new SequencesSentDataProvider(sequencesContainer.sent)
			);
			window.chartsWindows.addDataProvider(
				new SequencesInsertedDataProvider(sequencesContainer.inserted)
			);
			window.chartsWindows.addDataProvider(
				new SequencesForwardedDataProvider(sequencesContainer.forwarded)
			);
			window.chartsWindows.addDataProvider(
				new SequencesRecvDataProvider(sequencesContainer.recv)
			);
				
			
			/* -- Sequences window -- */
			// Assign the sequencesContainer for the video sequences window
			window.sequencesWindow.setSequencesContainer(sequencesContainer);
		}
		
		/**
		 * Update time
		 */ 
		private function updateTime():void
		{
			var time:uint = simulation.time; 
			window.setTime(time);
			view.setTime(time);
		}
		
		/**
		 * Jump to time
		 * 
		 * @param elapsed
		 */ 
		private function jumpToTime(elapsed:uint):void
		{
			simulation.jumpToTime(elapsed);
			updateTime();
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
		
		/**
		 * Handle play button click
		 * 
		 * @param event
		 */ 
		private function handlePlayButtonStateChange(event:Event):void
		{	
			if (!simulation.running) {
				simulation.start();
			}
			else {
				simulation.pause();
			}
		}
		
		/**
		 * Handle playback speed change
		 * 
		 * @param event
		 */ 
		private function handlePlaybackSpeedChange(event:Event):void
		{
			simulation.speed = window.playback.playbackSpeed.value;
		}
		
		/**
		 * Handle mobility area init
		 * 
		 * @param event
		 */
		private function handleMobilityAreaInit(event:Event):void
		{
			window.setPerimeterViewEnabled(true);	
		}
		
		/**
		 * Handle routing init
		 * 
		 * @param event
		 */ 
		private function handleRoutingInit(event:Event):void
		{
			window.setTopologyEnabled(true); // enable global topology trough routing
		}
		
		/**
		 * Handle topology init
		 * 
		 * @param event
		 */ 
		private function handleTopologyInit(event:Event):void
		{
			window.setLocalTopologyEnabled(true); 
		}
		
		/**
		 * Handle sequences init
		 * 
		 * @param event
		 */ 
		private function handleSequencesInit(event:Event):void
		{
			window.setSequencesEnabled(true);
		}
		
		/**
		 * Handle simulation ready
		 * 
		 * @param event
		 */ 
		private function handleSimulationReady(event:Event):void
		{
			window.playback.menu.enabled = true;
			window.setDuration(
				simulation.duration
			);
			window.playback.showLoader();
		}
		
		/**
		 * Handle simulation reset
		 * 
		 * @param event
		 */ 
		private function handleSimulationReset(event:Event):void
		{
			// Global Reset
			window.setTopologyEnabled(false);
		}
		
		/**
		 * Handle simulation timer
		 * 
		 * @param event
		 */ 
		private function handleSimulationTimer(event:TimerEvent):void
		{
			updateTime();
		}
		
		/**
		 * Handle simulation complete
		 * 
		 * @param event
		 */ 
		private function handleSimulationComplete(event:Event):void
		{
			window.playback.playButtonState = Playback.PLAY;
		}
		
		/**
		 * Handle parser timed event elapsed
		 * 
		 * @param event
		 */ 
		private function handleParserTimedEventElapsed(event:TimedEvent):void
		{
			if (simulation.duration > 0) {
				var value:Number = event.elapsed / simulation.duration * 100;
				window.setLoaded(value);
				simulation.setLoaded(value);
				window.playback.setLoaderValue(value);
			}
		}
		
		/**
		 * Handle parser event complete
		 * 
		 * @param event
		 */ 
		private function handleParserEventComplete(event:Event):void
		{
			window.setLoaded(100);	
			simulation.setLoaded(100);
			window.playback.setLoaderValue(100);
			setTimeout(window.playback.hideLoader, 1000);
		}
		
		/**
		 * Handle playback progress timer change value
		 * 
		 * @param event
		 */ 
		private function handlePlaybackProgressTimerElapsed(event:TimedEvent):void
		{
			if (!window.playback.buffering) {
				jumpToTime(event.elapsed);
			}
		}

		/**
		 * Handle playback progress timer change start
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerChangeStart(event:Event):void
		{
			if (simulation.running) {
				simulation.pause();
			}
		}
		
		/**
		 * Handle playback progress timer change end
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerChangeEnd(event:Event):void
		{
			if (!window.playback.buffering) {
				jumpToTime(window.playback.getTime());
				if (window.playback.isPlaying && !simulation.running) {
					simulation.start();
				}
			}
		}
		
		/**
		 * Handle playback timer load start
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerLoadStart(event:Event):void
		{
			if (simulation.running) {
				simulation.pause();
			}
		}
		
		/**
		 * Handle playback progress timer load start
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerLoadEnd(event:Event):void
		{
			jumpToTime(window.playback.getTime());
			if (window.playback.isPlaying && !simulation.running) {
				simulation.start();
			}
		}
			
	}
}