package vue;

import haxe.extern.Rest;

@:native("Vuex")
extern class Vuex {}

@:native("Vuex.Store")
extern class Store<T> implements IStore {
	public final state:T;
	public function new(options:StoreOptions<T>);
	@:overload(function(name:String, args:Rest<Any>):Void {})
	public function commit(name:String):Void;
}

@:remove
interface IStore {}

typedef StoreOptions<T> = {
	state:T,
	?mutations:Dynamic
}
