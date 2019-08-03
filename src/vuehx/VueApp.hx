package vuehx;
import vue.*;

abstract VueApp(Vue) {
	public inline function new(el:String = "#app"):Void {
		this = new Vue({el: el});
	}

	public static inline function component(comp:IVueComponent, ?name:String) {
		Vue.component(name == null ? comp.__name : name, comp.asComponent());
	}
}
