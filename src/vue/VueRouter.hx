package vue;

@:native("VueRouter")
extern class VueRouter {
	public final currentRoute:Route;
	public function new(options:{routes:Array<Route>, ?mode:String});
	public function go(index:Int):Void;
	public function replace(location:String, ?onComplete:() -> Void, ?onAbort:() -> Void):Void;
	public function push(path:String):Void;
	public function addRoutes(routes:Array<Route>):Void;
}
