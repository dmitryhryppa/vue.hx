package vuehx;

import vue.Vuex.Store;
import vue.Vuex.IStore;
import vue.*;

@:forward(options)
abstract App(Vue) {
	public inline function new(el:String = "#app") {
		this = new Vue({el: el});
	}

	public inline function getStore<T>():Null<Store<T>> {
		return this.options.store;
	}

	public static inline function component(comp:IComponent, ?name:String) {
		Vue.component(name == null ? comp.__name : name, comp.asComponent());
	}

	public static inline function use(extension:Any):Void {
		Vue.use(extension);
	}
}
