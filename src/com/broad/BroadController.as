package com.broad
{
	import com.broad.core.Simulation;
	import com.broad.core.aggregate.Aggregate;
	import com.broad.core.events.TimedEvent;
	import com.broad.core.network.graph.AdjacencyMatrix;
	import com.broad.core.network.graph.Graph;
	import com.broad.core.network.node.Node;
	import com.broad.core.network.node.NodeContainer;
	import com.broad.core.parser.TraceSourceParser;
	import com.broad.elements.buffer.Buffers;
	import com.broad.elements.buffer.BuffersDataProvider;
	import com.broad.elements.drops.Drops;
	import com.broad.elements.drops.DropsDataProvider;
	import com.broad.elements.mobility.Mobility;
	import com.broad.elements.mobility.MobilityArea;
	import com.broad.elements.mobility.Waypoint2D;
	import com.broad.elements.receptions.Receptions;
	import com.broad.elements.receptions.ReceptionsDataProvider;
	import com.broad.elements.routing.Routing;
	import com.broad.elements.routing.RoutingTable;
	import com.broad.elements.routing.RoutingTableEntry;
	import com.broad.elements.routing.SimpleRoute;
	import com.broad.elements.sequences.SequencesContainer;
	import com.broad.elements.sequences.providers.SequencesForwardedDataProvider;
	import com.broad.elements.sequences.providers.SequencesInsertedDataProvider;
	import com.broad.elements.sequences.providers.SequencesRecvDataProvider;
	import com.broad.elements.sequences.providers.SequencesSentDataProvider;
	import com.broad.elements.sequences.sources.SequencesForwarded;
	import com.broad.elements.sequences.sources.SequencesRecv;
	import com.broad.elements.sequences.sources.SequencesSent;
	import com.broad.elements.topology.Topology;
	import com.broad.elements.transmissions.Transmissions;
	import com.broad.elements.transmissions.TransmissionsBitrateDataProvider;
	import com.broad.elements.transmissions.TransmissionsDataProvider;
	import com.broad.io.FileReferenceReader;
	import com.broad.io.Reader;
	import com.broad.ui.menus.Playback;
	import com.broad.ui.menus.PlaybackContainer;
	import com.broad.ui.menus.ProgressTimeSlider;
	import com.broad.view.VisualizationView;
	import com.broad.view.components.GridView;
	import com.broad.view.components.LoaderView;
	import com.broad.view.components.MiniMapView;
	import com.broad.view.components.NodeSprite;
	import com.broad.view.components.NodeView;
	import com.broad.view.components.PerimeterView;
	import com.broad.view.components.StatsView;
	import com.broad.view.drawing.NodeBuffersDrawingManager;
	import com.broad.view.drawing.NodeDrawingManager;
	import com.broad.view.drawing.NodeDropsDrawingManager;
	import com.broad.view.drawing.NodeIDDrawingManager;
	import com.broad.view.drawing.NodeMobilityDrawingManager;
	import com.broad.view.drawing.NodeReceptionsDrawingManager;
	import com.broad.view.drawing.NodeRoutingDrawingManager;
	import com.broad.view.drawing.NodeTransmissionsDrawingManager;
	import com.broad.view.events.NodeSpriteEvent;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	import spark.components.Application;

	/**
	 * Gran
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class BroadController
	{
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param app
		 * @param window
		 */ 
		public function BroadController(app:Application, window:ApplicationWindow)
		{		
			setup(window);
			bindWindow(window);
			
			this.app 	= app;
			// this.app.frameRate = 30; // 30fps Manually set on the Main mxml file
			this.window = window; 
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/* reference to application and the main window */
		private var app:Application;
		private var window:ApplicationWindow;
		
		/* helper variables */
		private var ready:Boolean = false;
		private var first:Boolean = true;
		
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
		private var view:VisualizationView;
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
		
		/* --- Data Providers for charts -- */
		private var buffersDataProvider:BuffersDataProvider;
		private var dropsDataProvider:DropsDataProvider;
		private var receptionsDataProvider:ReceptionsDataProvider;
		private var transmissionsDataProvider:TransmissionsDataProvider;
		private var transmissionsBitrateDataProvider:TransmissionsBitrateDataProvider;
		private var sequencesSentDataProvider:SequencesSentDataProvider;
		private var sequencesInsertedDataProvider:SequencesInsertedDataProvider;
		private var sequencesForwardedDataProvider:SequencesForwardedDataProvider;
		private var sequencesRecvDataProvider:SequencesRecvDataProvider;
		
		
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
			parser.addTraceSource(sequencesContainer.inserted);
			parser.addTraceSource(sequencesContainer.forwarded);
			parser.addTraceSource(sequencesContainer.recv);
			
			reader.addEventListener(IOErrorEvent.IO_ERROR, handleReaderIOError);
			parser.addEventListener(TimedEvent.ELAPSED, handleParserTimedEventElapsed);
			parser.addEventListener(Event.COMPLETE, handleParserEventComplete);
			
			// Setup the view
			// 1. Append nodes
			view = window.visualizerView;
			
			// 2. Add views
			// 2.1 Grid view draws the grid
			// 2.2 Node view represents all the nodes in the system
			// 2.3 Mini map view adds the clickable displaced view of the nodes in the network
			// 2.4 Perimeter view adds the mobility perimeter 
			// 2.5 Loader view add the loading view which is presented when the user tries to jump 
			//     to a point in time that has not yet been loaded
			// 2.6 Stats view only used for debugging the frame rate of the application
			gridView = new GridView();
			view.addViewComponent(gridView);
			
			nodeView = new NodeView(nodeContainer)
			view.addViewComponent(nodeView);
			view.setDraggableView(nodeView);
			
			miniMapView = new MiniMapView(nodeView, gridView, nodeContainer, mobilityArea);
			view.addViewComponent(miniMapView);
			view.setMiniMapView(miniMapView);
			
			perimeterView = new PerimeterView(nodeView, mobilityArea);
			
			loaderView = new LoaderView();
			view.setLoaderView(loaderView);			
			
			statsView = new StatsView();
			view.addViewComponent(statsView);
			
			// 3 Append node drawing managers
			nodeIDDrawingManager = new NodeIDDrawingManager();
			nodeView.addDrawingManager(nodeIDDrawingManager);
			
			mobilityDrawingManager = new NodeMobilityDrawingManager(mobility, nodeView);
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
		
			// 4. Setup up the data providers for the
			buffersDataProvider = new BuffersDataProvider(buffers);
			dropsDataProvider = new DropsDataProvider(drops);
			receptionsDataProvider = new ReceptionsDataProvider(receptions);
			transmissionsDataProvider = new TransmissionsDataProvider(transmissions);
			transmissionsBitrateDataProvider = new TransmissionsBitrateDataProvider(transmissions);
			sequencesSentDataProvider = new SequencesSentDataProvider(sequencesContainer.sent);
			sequencesInsertedDataProvider = new SequencesInsertedDataProvider(sequencesContainer.inserted);
			sequencesForwardedDataProvider = new SequencesForwardedDataProvider(sequencesContainer.forwarded);
			sequencesRecvDataProvider = new SequencesRecvDataProvider(sequencesContainer.recv);

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
			window.chartsWindows.addDataProvider(buffersDataProvider);
			window.chartsWindows.addDataProvider(dropsDataProvider);
			window.chartsWindows.addDataProvider(receptionsDataProvider);
			window.chartsWindows.addDataProvider(transmissionsDataProvider);
			window.chartsWindows.addDataProvider(transmissionsBitrateDataProvider);
			window.chartsWindows.addDataProvider(sequencesSentDataProvider);
			window.chartsWindows.addDataProvider(sequencesInsertedDataProvider);
			window.chartsWindows.addDataProvider(sequencesForwardedDataProvider);
			window.chartsWindows.addDataProvider(sequencesRecvDataProvider);
				
			
			/* -- Sequences window -- */
			// Assign the sequencesContainer for the video sequences window
			window.sequencesWindow.setSequencesContainer(sequencesContainer);
		}
		
		
		/**
		 * Reset
		 */ 
		private function reset():void
		{
			first = false;
			ready = false;
		
			view.clear();
			window.reset();
		}
		
		/**
		 * Enable playback
		 */ 
		private function enablePlayback():void
		{
			window.setPlaybackEnabled(true);
		}
		
		/**
		 * Enable stats
		 */ 
		private function enableStats():void
		{
			window.setStatsEnabled(true);
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
		
		
		
		//--------------------------------------------------------------------------
		//
		// Simulation events
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle simulation ready
		 * 
		 * @param event
		 */ 
		private function handleSimulationReady(event:Event):void
		{
			ready = true;
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
			reset();
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
		
		
		
		//--------------------------------------------------------------------------
		//
		// Simulation Objects/TraceSource Init event handlers
		//
		//-------------------------------------------------------------------------
		
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
		
		
		//--------------------------------------------------------------------------
		//
		// Parser/Reader events
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle reader IOError
		 * 	Dispatched when the user tries to load a new file when an process is still not finished
		 * @param event
		 */ 
		private function handleReaderIOError(event:IOErrorEvent):void
		{
			Alert.show("The current file process job must finish before you can start a new one!", "Warning", Alert.OK);	
		}
		
		/**
		 * Handle parser timed event elapsed
		 * 	Tells us how much of the file has been parsed
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
				
				// if there are nodes on the view enable playback
				if (nodeView.nodeSprites.length > 0) {
					enablePlayback();
					enableStats();
				}
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
		
		
		//--------------------------------------------------------------------------
		//
		// Application Buttons events
		//
		//-------------------------------------------------------------------------
		
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
		
		
		//--------------------------------------------------------------------------
		//
		// Application Playback Progress & Speed event handlers
		//
		//-------------------------------------------------------------------------
		
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