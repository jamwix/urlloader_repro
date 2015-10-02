package;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLVariables;
import openfl.net.URLRequestMethod;
import openfl.net.URLRequestHeader;
import openfl.net.URLLoaderDataFormat;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.HTTPStatusEvent;

import cpp.vm.Thread;
import AssetManager;

class Main extends Sprite {
	
	
	private var _loader:URLLoader;
	private var _bm:Bitmap;
	private var _thread:Thread;

	public function new () {
		
		super ();
/*		
		_thread = Thread.create(function ():Void {
			while (true)
			{
				var msg:Dynamic = Thread.readMessage(true);
				if (msg == null || msg.data == null)
				{
					trace("Improperly formatted message: " + msg);
					return;
				}
				sys.io.File.saveBytes("/tmp/testpath.tar", msg.data);
			}
		});
		*/
		addEventListener(Event.ENTER_FRAME, addBitmap);

		var assets:AssetManager = new AssetManager();
		assets.syncManifest(15, "http://d1geib4acjj2ck.cloudfront.net/manifests/manifest.15.json.gz");
		//addBitmap();
		//doRequest();
	}

	private function addBitmap(?e:Event):Void
	{
		removeChild(_bm);

		_bm = new Bitmap (Assets.getBitmapData ("assets/openfl.png"), false);
		addChild (_bm);
		
		_bm.x = (stage.stageWidth - _bm.width) / 2;
		_bm.y = (stage.stageHeight - _bm.height) / 2;
	}

	private function doRequest():Void
	{
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.BINARY;
		addListeners();

		var request:URLRequest = new URLRequest("https://s3.amazonaws.com/cinemnb/tars/180.tar");
		request.method = URLRequestMethod.GET;

		_loader.load(request);
	}

	private function addListeners():Void
	{
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.addEventListener(Event.COMPLETE, onComplete);
		_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
	}

	private function removeListeners():Void
	{
		_loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.removeEventListener(Event.COMPLETE, onComplete);
		_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
	}

	private function onError(?e:Event):Void
	{
		trace("ERROR");
		removeListeners();
	}
	
	private function onComplete(?e:Event):Void
	{
		trace("COMPLETE");
		removeListeners();
		_thread.sendMessage({data: _loader.data});
		doRequest();
	}

	private function onStatus(?e:Event):Void
	{
		trace("STATUS");
	}
	
}
