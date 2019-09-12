package vue;

import vue.Vuex.Store;
import vue.VueRouter;
import haxe.extern.EitherType;
import js.html.HtmlElement;

/*
	Created at: 06 February 2019
	[Description]
 */
#if vuenpm
@:jsRequire("vue")
#end
@:native("Vue")
extern class Vue {
	public static function use(extension:Dynamic):Void;
	public static function component(tag:String, ?options:VueComponentOptions):Void;
	public var el:HtmlElement;
	@:native("$options")
	public var options:VueOptions<Any, Any>;
	public function new<T, M>(options:VueOptions<T, M>);

	public inline function getStore<T>():Null<Store<T>> {
		return untyped __js__("{0}.store", this.options);
	}
}

typedef VueOptions<TData, TMethods> = {
	el:EitherType<String, HtmlElement>,
	?store:Any,
	?data:TData,
	?methods:TMethods,
	?router:VueRouter
}
