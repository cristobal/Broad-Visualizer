package com.broad.ui.windows.charts
{
	import com.broad.core.aggregate.AggregateDataProvider;
	import com.broad.core.network.node.Node;
	import com.broad.ui.windows.BaseWindow;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.charts.AreaChart;
	import mx.charts.series.LineSeries;
	import mx.collections.ArrayCollection;
	import mx.controls.Spacer;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	import mx.graphics.Stroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.ComboBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalAlign;
	import spark.skins.spark.HSliderSkin;
	
	/**
	 * ChartsWindowContainer.as
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class ChartsWindow extends BaseWindow
	{
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	The color array for the lines draw
		 */ 
		private static var colors:Vector.<uint> = Vector.<uint>([0x0000ff,
			0x00FF00,
			0xFF0000,
			0xF6FF00,
			0xBB00FF,
			0xFF7300,
			0xFF0095,
			0xFF6622,
			0x70FAA3,
			0xAA8888
		]);
		
		/**
		 * @private
		 * 	A next id for the chart window's
		 */ 
		private static var nextOID:int = 1;
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */ 
		public function ChartsWindow()
		{
			super();			
			width = 500;
			height = 350;
		}

		
		/**
		 * @private
		 */ 
		private var progress:Number = 0;

		/**
		 * @private
		 */ 
		private var filteredNodes:Vector.<Node>;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var _duration:uint;
		
		/**
		 * @readwrite duration
		 */ 
		public function get duration():uint
		{
			return _duration;	
		}
		
		public function set duration(value:uint):void
		{
			_duration = value;
		}
		
		/**
		 * @private
		 */ 
		private var _oid:int = -1;
		
		/**
		 * @readonly oid
		 */ 
		public function get oid():int
		{
			if (_oid < 0) {
				_oid = nextOID++;
			}
			return _oid;
		}
		
		/**
		 * @private
		 */ 
		private var _nodes:Vector.<Node>;
		
		/**
		 * @readwrite nodes
		 */ 
		public function get nodes():Vector.<Node>
		{
			return _nodes;	
		}
		
		public function setNodes(value:Vector.<Node>):void
		{
			_nodes = value;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint;
		
		/**
		 * @readwrite time
		 */ 
		public function get time():uint
		{
			return _time;	
		}
		
		public function setTime(value:uint):void
		{
			if (_time  != value) {
				_time  = value;
				progress = time / duration;
				updateProgress();
			}
			
		}
		
		/**
		 * @readwrite minResolution
		 * Sets the minimum resolution allowed when drawing the graph
		 *
		 * @param value Resolution of the graph in milliseconds
		 */
		public function set minResolution(value:Number):void
		{
			resolutionSlider.minimum = value;
			resolutionSlider.stepSize    = (resolutionSlider.maximum - resolutionSlider.minimum) / 1000;
			resolutionSlider.snapInterval = resolutionSlider.snapInterval;
		}
		
		public function get minResolution():Number
		{
			return resolutionSlider.minimum;
		}
		
		/**
		 * @readwrite maxResolution
		 * Sets the maximum resolution allowed when drawing the graph
		 *
		 * @param value Resolution of the graph in milliseconds
		 */
		public function set maxResolution(value:Number):void
		{
			resolutionSlider.maximum      = value;
			resolutionSlider.stepSize     = (resolutionSlider.maximum - resolutionSlider.minimum) / 1000;
			resolutionSlider.snapInterval = resolutionSlider.snapInterval;
		}
		
		public function get maxResolution():Number
		{
			return resolutionSlider.maximum;
		}
		
		
	
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override protected function setup():void
		{
			title = "Charts - #" + String(oid);
			setupLabelsContainer();
			setupChartsContainer();
			setupOptionsContainer();
			setupNodesContainer();
			
			super.setup();
			updateProgress();
			invalidateDataProviders();
			setTimeout(updateProgress, 100);
		}
		
		/**
		 * @override
		 */ 
		override protected function onResizeChange():void
		{
			updateProgress();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Data Providers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var interests:Vector.<AggregateDataProvider> = new Vector.<AggregateDataProvider>();
		
		/**
		 * @private
		 */ 
		private var dataProviders:Vector.<AggregateDataProvider>;
		
		/**
		 * Set data providers
		 * 
		 * @param dataProviders
		 */ 
		public function setDataProviders(dataProviders:Vector.<AggregateDataProvider>):void
		{
			this.dataProviders = dataProviders;
			invalidateDataProviders();
		}
		
		/**
		 * Invalidate data providers
		 */ 
		private function invalidateDataProviders():void
		{
			if (!providersList) {
				return;
			}
			
			var list:ArrayCollection = new ArrayCollection();
			var provider:AggregateDataProvider;
			var item:Object;
			for (var i:int = 0, l:int = dataProviders.length; i < l; i++) {
				provider = dataProviders[i];
				item     = {label: provider.name, oid: provider.oid, id: i};
				list.addItem(item);
			}
			
			providersList.dataProvider = list;
			providersList.selectedItem = list[0];
		}
		
		/**
		 * Add select data provider
		 */ 
		private function addSelectedDataProvider(item:Object):void
		{
			var oid:String  = item.oid;
			var add:Boolean = true;
			
			for (var i:int = 0, l:int = interests.length; i < l; i++) {
				if (interests[i].oid == oid) {
					// interest already added
					add = false;
					break;
				}
			}
			
			if (add) {
				var provider:AggregateDataProvider;
				for (i = 0, l = dataProviders.length; i < l; i++) {
					if (dataProviders[i].oid == oid) {	
						provider = dataProviders[i];
						break;
					}
				}
				
				if (provider) {
					interests.push(provider);
					addChartLabel(item);
					invalidateInterests();
				}
			}
		}
		
		/**
		 * Remove data provider
		 * 
		 * @param item
		 */ 
		private function removeDataProvider(item:Object):void
		{
			
			var removed:Boolean = false;
			for (var i:int = interests.length; i--;) {
				if (interests[i].oid == item.oid) {
					interests.splice(i, 1);
					removed = true;
					break;
				}
			}
			
			if (removed) {
				invalidateInterests();
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Charts Labels Container
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var labelsContainer:BorderContainer;
		
		/**
		 * @private
		 */ 
		private var labels:Vector.<ChartLabel> = new Vector.<ChartLabel>();
		
		/**
		 * Setup labels container
		 */ 
		private function setupLabelsContainer():void
		{
			labelsContainer = new BorderContainer();			
			labelsContainer.setStyle("backgroundColor", "0xF5F5F5");	
			labelsContainer.setStyle("borderColor", "0xE5E5E5");	
			labelsContainer.setStyle("borderTop", 0);
			labelsContainer.setStyle("borderBottom", 0);
			labelsContainer.setStyle("borderRight", 0);
			labelsContainer.setStyle("left", 0);
			labelsContainer.setStyle("right", 0);
			labelsContainer.setStyle("top", 0);
			labelsContainer.height = 45;
			addElement(labelsContainer);
			
			labelsContainer.addEventListener(ResizeEvent.RESIZE, handleLabelsContainerResize);
		}
		
		/**
		 * Invalidate labels container display list
		 */ 
		private function invalidateLabelsContainerDisplayList():void
		{
			var w:Number = labelsContainer.width;
			
			var x:int = 0;
			var y:int = 0;
			var offset:int = 5;
			
			var label:ChartLabel;
			var rows:int = 0;
			var hidden:Boolean 
			for (var i:int = 0, l:int = labels.length; i < l; i++) {
				label   = labels[i];
				label.x = x;
				label.y = y;	
				label.visible = !hidden;
				x = label.x + label.width + offset;
				
				// check on next 
				if (i + 1 < l && labels[i + 1].width + x - offset > w) {
					y = label.height + offset;
					x = 0;
					rows++;					
				}
				
				
				if (rows == 2) {
					hidden = true;// we dont't show the rest until the user resized the window
				}
			}
		}
		
		/**
		 * Add chart label
		 * 
		 * @param item
		 */ 
		private function addChartLabel(item:Object):void
		{
			var color:uint = colors[0];
			if (labels.length > 0) {
				var taken:Boolean;
				for (var i:int = 0, l:int = colors.length; i < l; i++) {
					color = colors[i];
					taken = false;
					for (var j:int = labels.length; j--;) {
						if (labels[j].color == color) {
							taken = true;
							break;
						}
					}
					
					if (!taken) {
						break;
					}
				}
			}
			
			var label:ChartLabel = new ChartLabel(item, color);
			label.x = 0;
			if (labels.length > 0) {
				label.x = labels[labels.length - 1].x + labels[labels.length - 1].width + 5; 
			}
			labelsContainer.addElement(label);
			label.addEventListener(ChartLabel.REMOVE, handleDataProviderLabelRemove);
			labels.push(label);
			
			setTimeout(invalidateLabelsContainerDisplayList, 10);
		}
		
		/**
		 * Remove chart label
		 */ 
		private function removeChartLabel(label:ChartLabel):void
		{
			label.removeEventListener(ChartLabel.REMOVE, handleDataProviderLabelRemove);
			labelsContainer.removeElement(label);
			for (var i:int = labels.length; i--; ) {
				if (label == labels[i]) {
					labels.splice(i, 1);
					label = null;
					break;
				}
			}
			invalidateLabelsContainerDisplayList();
		}
		
		/**
		 * Get color for chart label by item
		 * 
		 * @param item
		 */ 
		private function getColorForChartLabelByitem(item:Object):uint
		{
			var color:uint = 0;
			for (var i:int = labels.length; i--;) {
				if (labels[i].item.oid == item.oid) {
					color = labels[i].color;
					break;
				}
			}
			
			return color;
		}
		
		/**
		 * Handle data provider label remove
		 * 
		 * @param event
		 */ 
		private function handleDataProviderLabelRemove(event:Event):void
		{
			var label:ChartLabel = ChartLabel(event.target);
			removeChartLabel(label);
			removeDataProvider(label.item);
		}
		
		/**
		 * Handle labels container resize
		 * 
		 * @param
		 */ 
		private function handleLabelsContainerResize(event:ResizeEvent):void
		{
			invalidateLabelsContainerDisplayList();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Charts Container
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	The container for all the charts components
		 */ 
		private var chartsContainer:Group;
		
		/**
		 * @private
		 */ 
		private var chart:AreaChart;
		
		/**
		 * @private
		 */ 
		private var chartAnnotations:UIComponent;
		
		/**
		 * @private
		 */ 
		private var chartNodesValue:Label;
	
		
		/**
		 * Setup charts container
		 */ 
		private function setupChartsContainer():void
		{
			chartsContainer = new Group();
			chartsContainer.setStyle("top", 47);
			chartsContainer.setStyle("right", 0);
			chartsContainer.setStyle("bottom", 30);
			chartsContainer.setStyle("left", 0);
			addElement(chartsContainer);
			
			chart = new AreaChart();
			chart.showDataTips = true;
			chart.setStyle("left", 0);
			chart.setStyle("right", 0);
			chart.setStyle("top", 0);
			chart.setStyle("bottom", 25);
			chartsContainer.addElement(chart);
			
			
			chartAnnotations = new UIComponent();
			chartAnnotations.setStyle("left", 46);
			chartAnnotations.setStyle("right", 15);
			chartAnnotations.setStyle("top", 10);
			chartAnnotations.setStyle("bottom", 50);
			chartsContainer.addElement(chartAnnotations);
			
			var label:Label = new Label();
			label.text = "Nodes:";
			label.setStyle("fontSize", "12");
			label.setStyle("fontSize", "bold");
			label.setStyle("left", 10);
			label.setStyle("bottom", 5);
			chartsContainer.addElement(label);
			
			chartNodesValue = new Label();
			chartNodesValue.text = "All";
			chartNodesValue.setStyle("fontFamily", "DejaVuSansMono");
			chartNodesValue.setStyle("fontSize", "10");
			chartNodesValue.setStyle("left", 60);
			chartNodesValue.setStyle("bottom", 5);
			chartsContainer.addElement(chartNodesValue);
		}
		
		/**
		 * Invalidate interests
		 */ 
		public function invalidateInterests():void
		{
			if (interests.length == 0 && chart.series) {
				chart.series = [];
				return;
			}
			
			var minValues:Array = [minResolution];
			var maxValues:Array = [maxResolution];
			var interest:AggregateDataProvider;
			for (var i:int = 0, l:int = interests.length; i < l; i++) {
				interest = interests[i];
				minValues.push(interest.minimumResolution);
				maxValues.push(interest.maximumResolution);
			}
			
			minResolution = Math.min.apply(Math.min, minValues);
			maxResolution = Math.max.apply(Math.max, maxValues);
			
			var series:Array = [];
			var lineSeries:LineSeries;
			var resolution:Number = resolutionSlider.value;
			var color:uint;
			var selectedNodes:Vector.<Node> = filteredNodes ? filteredNodes : nodes;
			for (i = 0; i < l; i++) {
				interest = interests[i];
				lineSeries = new LineSeries();
				lineSeries.dataProvider = interest.getValues(resolution, selectedNodes);
				lineSeries.xField = "hAxis";
				lineSeries.yField = "vAxis";
				lineSeries.displayName = interest.name;
				color = getColorForChartLabelByitem({oid: interest.oid});
				lineSeries.setStyle("lineStroke", new Stroke(color, 2));
				
				if (ArrayCollection(lineSeries.dataProvider).length > 0) {
					series.push(lineSeries);
				}
			}
			
			
			chart.series = series;
		}
		
		/**
		 * Update progress
		 */ 
		protected function updateProgress():void
		{
			if (chartAnnotations.width == 0) {
				chartAnnotations.invalidateSize();
			}
			
			chartAnnotations.graphics.clear();
			chartAnnotations.graphics.beginFill(0xbb3366);
			chartAnnotations.graphics.drawRect(progress * chartAnnotations.width, 0, 2, chartAnnotations.height);
			chartAnnotations.graphics.endFill();
		}
		
		/**
		 * Update selected node values
		 */ 
		private function updateSelectedNodeValues():void
		{
			filteredNodes = null; // reset state
			// only filter when all are not selected
			if (!selectAllCheckboxes.selected) {
				filteredNodes = _nodes.concat(); // create shallow copy
				
				var list:Vector.<int> = new Vector.<int>; 
				var id:int;
				for (var i:int = filteredNodes.length; i--;) {
					id = filteredNodes[i].id;
					for (var j:int = checkboxes.length; j--;) {
						if (checkboxes[j].nodeID == id) {
							if (!checkboxes[j].selected) {
								filteredNodes.splice(i, 1);	
							}
							else {
								list.push(id);	
							}
							break; // found node break and continue
						}
					}
				}
				if (filteredNodes.length == 0) {
					chartNodesValue.text = "None";
				}
				else {
					chartNodesValue.text = "#" + list.join(" #");
				}
			}
			else {
				chartNodesValue.text = "All";
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Options Container
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	The holder for all the options
		 */ 
		private var optionsContainer:BorderContainer;
		
		
		/**
		 * @private 
		 */ 
		private var resolutionSlider:ResolutionSlider;
		
		/**
		 * @private 
		 */ 
		private var providersList:ComboBox;
		
		/**
		 * @private 
		 */ 
		private var addProviderButton:Button;
		
		/**
		 * @private 
		 */ 
		private var filterNodesButton:Button;
	
		/**
		 * Setup options container
		 */ 
		private function setupOptionsContainer():void
		{
			
			optionsContainer= new BorderContainer();
			optionsContainer.setStyle("backgroundColor", "0xF1F1F1");
			optionsContainer.setStyle("borderColor", "0xCCCCCC" );
			optionsContainer.setStyle("left", 0);
			optionsContainer.setStyle("right", 0);
			optionsContainer.setStyle("bottom", 0);
			optionsContainer.height = 30;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign ="center";
			horizontalLayout.verticalAlign ="middle";
			optionsContainer.layout = horizontalLayout;
			contentGroup.addElement(optionsContainer);
			
			var label:Label = new Label();
			label.text = "Resolution:";
			optionsContainer.addElement(label);
			
			resolutionSlider = new ResolutionSlider();
			resolutionSlider.minimum = 0;
			resolutionSlider.maximum = 10000;
			resolutionSlider.value = 10000;
			resolutionSlider.stepSize = 1;
			resolutionSlider.snapInterval = 1;
			resolutionSlider.addEventListener(Event.CHANGE, handleResolutionSliderChange);
			optionsContainer.addElement(resolutionSlider);
			
			var spacer:Spacer = new Spacer();
			spacer.setStyle("width", "100%");
			optionsContainer.addElement(spacer);
			
			providersList = new ComboBox();
			providersList.selectedIndex = 0;
			providersList.labelField    = "label";
			optionsContainer.addElement(providersList);
			
			addProviderButton = new Button();
			addProviderButton.label = "add";
			addProviderButton.width = 50;
			addProviderButton.addEventListener(MouseEvent.CLICK, handleAddProviderButtonClick);
			optionsContainer.addElement(addProviderButton);
			
			
			
			filterNodesButton = new Button();
			filterNodesButton.label = "filter";
			filterNodesButton.width = 50;
			filterNodesButton.addEventListener(MouseEvent.CLICK, handleFilterNodesButtonClick);
			optionsContainer.addElement(filterNodesButton);
		}
		
		/**
		 * Handle add provider button click
		 * 
		 * @param event
		 */ 
		private function handleAddProviderButtonClick(event:MouseEvent):void
		{
			addSelectedDataProvider(providersList.selectedItem);
		}
		
		
		/**
		 * Handle filter button click
		 * 
		 * @param event
		 */ 
		private function handleFilterNodesButtonClick(event:MouseEvent):void
		{
			if (nodesContainer.visible) {
				updateSelectedNodeValues();
				invalidateInterests();
			}
			nodesContainer.visible = !nodesContainer.visible;	
		}
		
		
		/**
		 * Handle resolution slider change
		 * 
		 * @param event
		 */ 
		private function handleResolutionSliderChange(event:Event):void
		{
			invalidateInterests();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Nodes Container
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var nodesContainer:BorderContainer;
		
		/**
		 * @private
		 */ 
		private var checkboxesContainer:Group;
		
		/**
		 * @private
		 */ 
		private var selectAllCheckboxes:CheckBox;
		
		/**
		 * @private
		 */ 
		private var selectNoneCheckboxes:CheckBox;
		
		/**
		 * @private
		 */ 
		private var checkboxes:Vector.<NodeCheckBox> = new Vector.<NodeCheckBox>();
		
		/**
		 * @private
		 */ 
		private var checkboxNeedsInvalidation:Boolean = true;
		
		/**
		 * Setup nodes container
		 */ 
		private function setupNodesContainer():void
		{
			nodesContainer = new BorderContainer();
			nodesContainer.setStyle("backgroundColor", "0x363636");
			nodesContainer.setStyle("borderColor", "0x1B1B1b");
			nodesContainer.setStyle("top", 47);
			nodesContainer.setStyle("right", 0);
			nodesContainer.setStyle("bottom", 30);
			nodesContainer.setStyle("left", 0);
			nodesContainer.visible = false;
			contentGroup.addElement(nodesContainer);
			
			var label:Label = new Label();
			label.text = "Select nodes:";
			label.setStyle("fontSize", 15);
			label.setStyle("top", 10);
			label.setStyle("left", 10);
			label.setStyle("color", "0xFAFAFA");
			label.setStyle("fontWeight", "bold");
			nodesContainer.addElement(label);
			
			
			// -- Select all
			selectAllCheckboxes = new CheckBox();
			selectAllCheckboxes.addEventListener(Event.CHANGE, handleSelectAllNodesEventChange);
			selectAllCheckboxes.setStyle("left", 10);
			selectAllCheckboxes.setStyle("top", 30);
			selectAllCheckboxes.selected = true;
			nodesContainer.addElement(selectAllCheckboxes);
			
			label = new Label();
			label.text = "All";
			label.setStyle("left", 28);
			label.setStyle("top", 33);
			label.setStyle("fontSize", 13);
			label.setStyle("color", "0xFAFAFA");
			label.setStyle("fontWeight", "bold");
			nodesContainer.addElement(label);
			
			
			// -- Select none
			selectNoneCheckboxes = new CheckBox();
			selectNoneCheckboxes.addEventListener(Event.CHANGE, handleSelectNoneNodesEventChange);
			selectNoneCheckboxes.setStyle("left", 67);
			selectNoneCheckboxes.setStyle("top", 30);
			selectNoneCheckboxes.selected = false;
			nodesContainer.addElement(selectNoneCheckboxes);
			
			
			// -- Label
			label = new Label();
			label.text = "None";
			label.setStyle("left", 85);
			label.setStyle("top", 33);
			label.setStyle("fontSize", 13);
			label.setStyle("color", "0xFAFAFA");
			label.setStyle("fontWeight", "bold");
			nodesContainer.addElement(label);
			
			
			// -- Checkboxes
			checkboxesContainer = new Group();
			var tileLayout:TileLayout = new TileLayout();
			tileLayout.verticalAlign   = VerticalAlign.TOP;
			tileLayout.horizontalAlign = HorizontalAlign.LEFT;
			tileLayout.paddingLeft = 10;
			tileLayout.paddingBottom = 5;
			checkboxesContainer.layout = tileLayout;
			checkboxesContainer.setStyle("top", 65);
			checkboxesContainer.setStyle("bottom", 0);
			checkboxesContainer.setStyle("left", 0);
			checkboxesContainer.setStyle("right", 0);
			nodesContainer.addElement(checkboxesContainer);
			
			var node:Node;
			var checkbox:NodeCheckBox;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node = nodes[i];
				checkbox = new NodeCheckBox(node.id);
				checkbox.selected = true;
				checkbox.addEventListener(Event.CHANGE, handleNodeCheckboxChange);
				checkboxesContainer.addElement(checkbox);
				checkboxes.push(checkbox);
			}
		}
		
		/**
		 * Handle select all nodes event change
		 * 
		 * @param event
		 */ 
		private function handleSelectAllNodesEventChange(event:Event):void
		{
			if (selectAllCheckboxes.selected) {
				checkboxNeedsInvalidation = false;
				for (var i:int = checkboxes.length; i--;) {
					if (!checkboxes[i].selected) {
						checkboxes[i].selected = true;
					}
				}
				selectNoneCheckboxes.selected = false;
				checkboxNeedsInvalidation = true;
			}
		}
		
		/**
		 * Handle select none nodes event change
		 * 
		 * @param event
		 */  
		private function handleSelectNoneNodesEventChange(event:Event):void
		{
			if (selectNoneCheckboxes.selected) {
				checkboxNeedsInvalidation = false;
				for (var i:int = checkboxes.length; i--;) {
					if (checkboxes[i].selected) {
						checkboxes[i].selected = false;
					}
				}
				selectAllCheckboxes.selected = false;
				checkboxNeedsInvalidation = true;
			}
		}
		
		/**
		 * Handle node checkbox change
		 * 
		 * @param event
		 */ 
		private function handleNodeCheckboxChange(event:Event):void
		{
			if (!checkboxNeedsInvalidation) {
				return;
			}
			
			var on:Boolean  = true;
			var off:Boolean = true;
			for (var i:int = checkboxes.length; i--;) {
				if (!checkboxes[i].selected && on) {
					on = false;
				}
				else if(checkboxes[i].selected && off) {
					off = false;
				}
			}
			selectAllCheckboxes.selected = on;
			selectNoneCheckboxes.selected = off;
			
		}
		
		
	}
}