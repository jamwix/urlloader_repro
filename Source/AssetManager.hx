package;

import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequestMethod;
import openfl.events.EventDispatcher;
import openfl.events.Event;
import openfl.utils.ByteArray;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.Json;
import haxe.Timer;
import haxe.crypto.Md5;

import sys.FileSystem;
import sys.io.File;

import JWRequest;

class AssetManager extends EventDispatcher
{
	
	private static var URLS:Array<String> = [
		"http://d1geib4acjj2ck.cloudfront.net/tars/190.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/189.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/188.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/187.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/186.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/185.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/184.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/183.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/182.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/181.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/180.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/179.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/178.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/177.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/176.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/175.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/174.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/173.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/100.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/101.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/102.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/103.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/104.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/105.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/106.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/107.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/108.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/109.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/110.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/111.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/112.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/113.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/114.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/115.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/116.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/117.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/118.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/119.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/120.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/121.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/122.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/123.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/124.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/125.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/126.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/127.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/128.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/129.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/130.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/131.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/132.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/133.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/134.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/135.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/136.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/137.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/138.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/139.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/140.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/141.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/142.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/143.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/156.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/157.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/158.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/159.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/160.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/161.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/162.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/163.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/164.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/165.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/166.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/167.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/168.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/169.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/170.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/171.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/172.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/150.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/151.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/152.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/153.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/154.tar",
		"http://d1geib4acjj2ck.cloudfront.net/tars/155.tar",
	];

	public function new()
	{
		super();
	}

	public function start()
	{
		var files:Array<String> = URLS.copy();
		getAssetFiles(files);
	}

	private function getAssetFiles(files:Array<Dynamic>):Void
	{
		var file:Dynamic = files.pop();

		trace("GETTING FILE: " + file);
		getAssetFile(file, function(res:Dynamic) {
			if (res.err != null)
			{
				trace("Asset download error - CODE: " + res.code + 
					  " MSG: " + res.err);
				return;
			}

			trace("DOWNLOADED FILE: " + file);

			getAssetFiles(files);
		});
	}

	public function getAssetFile(url:String, cb:Dynamic->Void):Void
	{
		trace("GETTING: " + url);
		new JWRequest(url, URLRequestMethod.GET, URLLoaderDataFormat.BINARY, 
				      null, cb); 
	}
}
