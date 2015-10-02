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
	
	private var _manifestMd5:String = null;
	private var _configMd5:String = null;
	private var _allowStart:Bool = true;

	public function new()
	{
		super();
		_manifestMd5 = "beb5498ed61a9500b83449751a5f4de5";
	}


	private function readGzipString(bytes:Bytes):String
	{
		var bytesInput:BytesInput = new BytesInput(bytes);
		var bo:BytesOutput = new haxe.io.BytesOutput();
		var reader:format.gz.Reader = new format.gz.Reader(bytesInput);

		try
		{
			reader.readHeader();
			reader.readData(bo);
		}
		catch (err:String)
		{
			trace("Unable to ungzip bytes");
			return null;
		}

		if (bo == null)
		{
			trace("No output bytes from gzip read");
			return null;
		}

		var strBytes:Bytes = bo.getBytes();
		if (strBytes == null)
		{
			trace("Unable to get bytes from gzip bytesoutput");
			return null;
		}

		var configStr:String = null;
		try
		{
			configStr = strBytes.toString();	
		}
		catch(strErr:String)
		{
			trace("Unable to convert gzip bytes to string");
			return null;
		}

		return configStr;
	}

	public function syncManifest(version:Int, url:String):Void
	{
		getManifest(url);
	}

	private function getManifest(url:String):Void
	{
		new JWRequest(url, URLRequestMethod.GET, URLLoaderDataFormat.BINARY, null,
				      onManifestDownloaded); 
	}

	private function onManifestDownloaded(res:Dynamic):Void
	{
		if (res.err != null)
		{
			trace("Manifest download error - CODE: " + res.code + 
				  " MSG: " + res.err);
			return;
		}

		if (res.data == null)
		{
			trace("Manifest request returned no data");
			return;
		}

		var manifestBytes:Bytes = res.data;
		var manifestStr:String = readGzipString(manifestBytes);
		if (manifestStr == null)
		{
			trace("Unable to ungzip manifest");
			return;
		}

		var manifestMd5:String = Md5.encode(manifestStr);
		if (manifestMd5 != _manifestMd5)
		{
			trace("Manifest MD5 mismatch. aborting.");
			return;
		}

		var manifest:Dynamic = null;
		try 
		{
			manifest = Json.parse(manifestStr);
		}
		catch (msg:String)
		{
			trace("Unable to parse manifest data: " + msg);
			return;
		}

		if (!isManifestValid(manifest))
		{
			trace("Manifest is improperly formatted");
			return;
		}

		var files:Array<Dynamic> = manifest.files;
		//trace("MANIFEST FILES: " + files);
		var filesCopy:Array<Dynamic> = files.copy();
		getAssetFiles(filesCopy);
	}

	private function isManifestValid(manifest:Dynamic):Bool
	{
		if (manifest == null) return false;
		if (manifest.version == null) return false;
		if (manifest.files == null) return false;

		var files:Array<Dynamic> = manifest.files;


		for (file in files)
		{
			if (file.name == null) return false;
			if (file.url == null) return false;
		}

		return true;
	}

	private function getAssetFiles(files:Array<Dynamic>):Void
	{
		if (files.length <= 0)
		{
			trace("No more assets to download. Asset sync complete.");
			return;
		}

		var file:Dynamic = files.pop();

		trace("GETTING FILE: " + file);
		getAssetFile(file.url, function(res:Dynamic) {
			if (res.err != null)
			{
				trace("Asset download error - CODE: " + res.code + 
					  " MSG: " + res.err);
				return;
			}

			trace("SENDING BYTES TO THREAD FOR: " + file);
			var bytes:Bytes = res.data;

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
