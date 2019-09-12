package vuehx;

import vue.VueComponentOptions;

@:remove
@:autoBuild(vuehx.ComponentBuilder.build())
interface IComponent {
	public final __name:String;
	function asComponent():Dynamic;
}
