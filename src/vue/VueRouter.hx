package vue;

@:native("VueRouter")
extern class VueRouter {
	public function new(options:{routes:Array<Route>});
	public function go(index:Int):Void;
	public function replace(location:String, ?onComplete:() -> Void, ?onAbort:() -> Void):Void;
	public function push(path:String):Void;
	public function addRoutes(route:Array<Route>):Void;
}
