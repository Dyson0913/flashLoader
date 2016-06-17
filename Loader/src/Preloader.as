package 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.getDefinitionByName;
	import com.adobe.serialization.json.JSON;
	import flash.display.MovieClip;	
		
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	import com.istrong.log.*;
	/**
	 * ...
	 * @author hhg4092
	 */
	[SWF(backgroundColor = "#000000")]
	public class Preloader extends MovieClip 
	{
		public var loadingPro:MovieClip;
		public var _para:String;
		
		public var _domain:String;
		public var _loading_path:String;
		public var _containner_name:String;
		public var config:String;
		
		public var _loader:Loader = new Loader();
		public var _Gameconfig:URLLoader;
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.SHOW_ALL;
				stage.align = StageAlign.TOP;
			}
			
			//TODO show loader			
			
			
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
		}
		
		private function checkFrame(e:Event):void 
		{
			if (this.loaderInfo.parameters["para"] != undefined)
			{    
				var token:String = this.loaderInfo.parameters["para"];				
				//loadingPro._log.text = token;
				_para = token;
			}
			
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			
			// TODO hide loader
			startup();
		}
		
	
		private function startup():void 
		{
			Logger.displayLevel = LogLevel.DEBUG;
			Logger.addProvider(new ArthropodLogProvider(), "Arthropod");
			
			//FOR TEST
			//_para = "{ \"accessToken\":\"c9f0f895fb98ab9159f51fd0297e236d\"}";
			
			if ( CONFIG::debug ) 
			{				
				_containner_name = "Lobby.swf"
				//_loading_path = "http://106.186.116.216:8000/static/";
				_loading_path = "http://52.197.7.184/swf/";
			}
			else
			{
				_containner_name = "Lobby.swf"
				_loading_path = "http://www.mm9900.net/swf/";
			}
			
			var result:Object  = JSON.decode(_para);			
			_para = result.accessToken;
			config = _loading_path +"gameconfig.json";
			
			Logger.log("loader token " + _para, 0, 0, false);
			Logger.log("loader _loading_path " + _loading_path, 0, 0, false);
			Logger.log("loader config " + config, 0, 0, false);
			
			load_config(config);
		}	
		
		private function load_config(config:String):void
		{
			Logger.log("1111"  , 0, 0, false);
			_Gameconfig = new URLLoader();
			_Gameconfig.addEventListener(Event.COMPLETE, configload); //載入聊天禁言清單 完成後執行 儲存清單內容			
			_Gameconfig.dataFormat =  URLLoaderDataFormat.BINARY; 
			_Gameconfig.load(new URLRequest(config)); 
			Logger.log("2222"  , 0, 0, false);
			Logger.log("loader config " + config, 0, 0, false);
		}
		
			public function configpro(e:Event):void
			{
				Logger.log("configpro ", 0, 0, false);
			}
		
		public function configload(e:Event):void
		{
			Logger.log("configload ok 1", 0, 0, false);
			var ba:ByteArray = ByteArray(URLLoader(e.target).data); //把載入文字 丟入Byte陣列裡面
		    var utf8Str:String = ba.readMultiByte(ba.length, 'utf8'); //把Byte陣列 轉 UTF8 格式		    
		    var result:Object  = JSON.decode(utf8Str);
		  
			Logger.log("configload ok 2", 0, 0, false);
			if ( CONFIG::debug ) _domain = result.development.DomainName[0].lobby_ws;
			else _domain =  result.online.DomainName[0].lobby_ws
			Logger.log("configload ok 3", 0, 0, false);
		  
			Load_cotainer();
		}
		
		private function Load_cotainer():void
		{
			loadingPro = new my_loader();		
			addChild(loadingPro);
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadend);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, gameprogress);			
			var url:URLRequest = new URLRequest(_loading_path + _containner_name);			
			Logger.log("loader address= " + _loading_path + _containner_name, 0, 0, false);
			var loaderContext:LoaderContext = new LoaderContext(false, new ApplicationDomain());
				
			_loader.load( url, loaderContext);
		}
		
		private function gameprogress(e:ProgressEvent):void 
		{
			// TODO update loader
			var total:Number = Math.round( e.bytesTotal/ 1024);
			var loaded:Number = Math.round(e.bytesLoaded / 1024);
			var percent:Number = Math.round(loaded / total * 100);
			
			loadingPro["_percent"].text = percent.toString() + "%";		
			var y:int = loadingPro["_mask"].y;
			loadingPro["_mask"].y =  622 -  ( 164 *  (percent / 100));			
		}
		
		private function loadend(event:Event):void
		{			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadend);
			
			if ( (_loader.content as MovieClip )["pass"] != null)
			{
				var msg:Object = { "accessToken":_para,"loading_path":_loading_path,"domain":_domain };
				var jsonString:String = JSON.encode(msg);
				var result:Object  = JSON.decode(jsonString);	
				(_loader.content as MovieClip)["pass"](result);			
			}
				
			addChild(_loader);
			removeChild(loadingPro);		
		}
		
		
		
	}
	
}