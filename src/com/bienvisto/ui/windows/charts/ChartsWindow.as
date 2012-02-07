package com.bienvisto.ui.windows.charts
{
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.ui.windows.BaseWindow;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.charts.AreaChart;
	import mx.charts.chartClasses.CartesianDataCanvas;
	import mx.charts.series.LineSeries;
	import mx.collections.ArrayCollection;
	import mx.controls.Spacer;
	import mx.core.FlexShape;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.graphics.Stroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.components.NumericStepper;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.skins.spark.HSliderSkin;
	import spark.skins.spark.TitleWindowSkin;
	
	// TODO: Switch to slider if possible
	/**
	 * ChartsWindowContainer.as
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class ChartsWindow extends BaseWindow
	{
		/**
		 * @private
		 */ 
		private static var nextOID:int = 1;
		
		/**
		 * Constructor
		 */ 
		public function ChartsWindow()
		{
			super();			
			width = 500;
			height = 300;
		}
		
		/**
		 * @public
		 */ 
		public var resolutionSlider:NumericStepper; //NumericStepper;
		
		/**
		 * @public
		 */ 
		public var providersComboBox:ComboBox;
		
		/**
		 * @public
		 */ 
		public var addProviderButton:Button;
		
		/**
		 * @private
		 */ 
		private var labelsContainer:BorderContainer;
		
		/**
		 * @private
		 */ 
		private var chart:AreaChart;
		
		/**
		 * @protected
		 */ 
		private var chartAnnotations:UIComponent;
		
		/**
		 * @private
		 */ 
		private var progress:Number = 0;
		
		/**
		 * @private
		 */ 
		private var interests:Vector.<AggregateDataProvider> = new Vector.<AggregateDataProvider>();
		
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
			trace("new minResolution value:", value);
			resolutionSlider.minimum = value;
			resolutionSlider.stepSize = (resolutionSlider.maximum - resolutionSlider.minimum) / 1000;
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
			trace("new maxResolution value:", value);
			resolutionSlider.maximum = value;
			resolutionSlider.stepSize = (resolutionSlider.maximum - resolutionSlider.minimum) / 1000;
		}
		
		public function get maxResolution():Number
		{
			return resolutionSlider.maximum;
		}
		
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
			if (!providersComboBox) {
				return;
			}
			
			var list:ArrayCollection = new ArrayCollection();
			var provider:AggregateDataProvider;
			var item:Object;
			for (var i:int = 0, l:int = dataProviders.length; i < l; i++) {
				provider = dataProviders[i];
				item     = {label: provider.name, oid: provider.oid, id: i, color: provider.color};
				list.addItem(item);
			}
			
			providersComboBox.dataProvider = list;
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
					var label:DataProviderLabel = new DataProviderLabel(provider);
					label.addEventListener(DataProviderLabel.REMOVE, handleDataProviderLabelRemove);
					labelsContainer.addElement(label);
					interests.push(provider);
					invalidateInterests();
				}
			}
		}
		
		/**
		 * Remove data provider label
		 * 
		 * @param label
		 */ 
		private function removeDataProviderLabel(label:DataProviderLabel):void
		{
		
			var interest:AggregateDataProvider = label.provider;
			var removed:Boolean = false;
			for (var i:int = interests.length; i--;) {
				if (interests[i].oid == interest.oid) {
					interests.splice(i, 1);
					removed = true;
					break;
				}
			}
			
			
			if (removed) {
				invalidateInterests();
			}
			
			try {
				labelsContainer.removeElement(label);
			}
			catch(error:Error) {
					
			}
		}
		
		/**
		 * Invalidate interests
		 */ 
		private function invalidateInterests():void
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
			for (i = 0; i < l; i++) {
				interest = interests[i];
				lineSeries = new LineSeries();
				lineSeries.dataProvider = interest.getList(resolution, nodes);
				lineSeries.xField = "hAxis";
				lineSeries.yField = "vAxis";
				lineSeries.displayName = interest.name;
				lineSeries.setStyle("lineStroke", new Stroke(interest.color, 2));
				
				if (ArrayCollection(lineSeries.dataProvider).length > 0) {
					series.push(lineSeries);
				}
			}
			
			if (series.length > 0) {
				chart.series = series;
			}
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
		 * @override
		 */ 
		override protected function onResizeChange():void
		{
			updateProgress();
		}
		
		/**
		 * @override
		 */ 
		override protected function setup():void
		{
			
			title = "Charts - #" + String(oid);
			
			labelsContainer = new BorderContainer();			
			labelsContainer.setStyle("backgroundColor", "0xf1f1f1");	
			labelsContainer.setStyle("borderColor", "0xcccccc");	
			labelsContainer.setStyle("left", 0);
			labelsContainer.setStyle("right", 0);
			labelsContainer.height = 40;
			
			var layout:TileLayout = new TileLayout();
			layout.horizontalAlign = "left";
			layout.verticalAlign   = "top"; 
			labelsContainer.layout = layout;
			contentGroup.addElement(labelsContainer);
			
			chart = new AreaChart();
			chart.showDataTips = true;
			chart.setStyle("left", 0);
			chart.setStyle("right", 0);
			chart.setStyle("top", 40);
			chart.setStyle("bottom", 30);
			contentGroup.addElement(chart);
			
			chartAnnotations = new UIComponent();
			chartAnnotations.setStyle("left", 46);
			chartAnnotations.setStyle("right", 15);
			chartAnnotations.setStyle("top", 50);
			chartAnnotations.setStyle("bottom", 55);
			contentGroup.addElement(chartAnnotations);
		
			var borderContainer:BorderContainer = new BorderContainer();
			borderContainer.setStyle("backgroundColor", "0xF1F1F1");
			borderContainer.setStyle("borderColor", "0xCCCCCC" );
			borderContainer.setStyle("left", 0);
			borderContainer.setStyle("right", 0);
			borderContainer.setStyle("bottom", 0);
			borderContainer.height = 30;
			var hl:HorizontalLayout = new HorizontalLayout();
			hl.horizontalAlign ="center" 
			hl.verticalAlign ="middle";
			borderContainer.layout = hl;
			contentGroup.addElement(borderContainer);
		
			var label:Label = new Label();
			label.text = "Resolution:";
			borderContainer.addElement(label);
			
			
			resolutionSlider = new NumericStepper();
			resolutionSlider.minimum = 0;
			resolutionSlider.maximum = 10000;
			resolutionSlider.value = 1000;
			resolutionSlider.stepSize = 100;
			resolutionSlider.snapInterval = 100;
			resolutionSlider.setStyle("liveDragging", "false");
			// resolutionSlider.width = 100;
			borderContainer.addElement(resolutionSlider);
			
			var spacer:Spacer = new Spacer();
			spacer.setStyle("width", "100%");
			borderContainer.addElement(spacer);
			
			providersComboBox = new ComboBox();
			providersComboBox.width = 150;
			providersComboBox.selectedIndex = 0;
			providersComboBox.labelField    = "label";
			borderContainer.addElement(providersComboBox);
			
			addProviderButton = new Button();
			addProviderButton.label = "add";
			addProviderButton.width = 50;
			addProviderButton.addEventListener(MouseEvent.CLICK, handleAddProviderButtonClick);
			borderContainer.addElement(addProviderButton);
			
			super.setup();
			updateProgress();
			invalidateDataProviders();
			setTimeout(updateProgress, 100);
		}
		
		
		/**
		 * Handle add provider button click
		 * 
		 * @param event
		 */ 
		private function handleAddProviderButtonClick(event:MouseEvent):void
		{
			addSelectedDataProvider(providersComboBox.selectedItem);
		}		
		
		/**
		 * Handle data provider label remove
		 * 
		 * @param event
		 */ 
		private function handleDataProviderLabelRemove(event:Event):void
		{
			removeDataProviderLabel(DataProviderLabel(event.target));	
		}
		
	}
}