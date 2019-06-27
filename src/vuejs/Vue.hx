package vue;

import vue.VueRouter;
import haxe.extern.EitherType;
import js.html.HtmlElement;

/*
	Created at: 06 February 2019
	[Description]
 */
@:native("Vue")
extern class Vue {
	public static function use(extension:Dynamic):Void;
	public static function component(tag:String, ?options:Any):Void;
	public var el:HtmlElement;
	@:native("$options")
	public var options:VueOptions<Any>;
	public function new<T>(options:VueOptions<T>);
}

typedef VueOptions<T> = {
	el:EitherType<String, HtmlElement>,
	data:T,
	?methods:Any,
	?router:VueRouter
}
