package; 

import cpp.vm.Thread;
import haxe.Timer;

import JamThread;

class ThreadManager
{

	private var _threads:Array<JamThread>;

	public function new()
	{
		_threads = new Array<JamThread>();
	}

	public function spawn(mainLoop:Dynamic->Dynamic, cb:Dynamic->Void):JamThread
	{
		var newId:Int = _threads.length;
		var thread:JamThread = new JamThread(mainLoop, cb);
		_threads.push(thread);
		thread.sendMessage({id: newId, main: Thread.current()});
		return thread;
	}

	public function update():Void
	{
		var startTime:Int = openfl.Lib.getTimer();
		var dt:Int = 0;
		while (dt < 10)
		{
			var msg:Dynamic = Thread.readMessage(false);
			if (msg == null) return;

			if (msg.id == null)
			{
				trace("Thread message had no id: " + msg);
				continue;
			}

			var id:Int = msg.id;
			if (id >= _threads.length || id < 0)
			{
				trace("Thread id is out of bounds: " + id);
				continue;
			}

			var thread:JamThread = _threads[id];
			if (thread == null)
			{
				trace("No Thread by id of: " + id);
				continue;
			}

			thread.processMessage(msg.msg);

			dt = openfl.Lib.getTimer() - startTime;
		}
	}
}
