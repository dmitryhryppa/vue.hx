package;
import js.Browser;
import vue.*;
import vuehx.IVueComponent;

//Path to the template file:
@:vue.template("./MyTemplate.vue")
class Index implements IVueComponent {
	static function main() {
		//Register component
		Vue.component("index-comp", new Index().asComponent());

		//Init vue
		final vm = new Vue({el: "#app"});
	}

	@:vue.data
	final message:String = "Hello World!";

	function new() {
	}

	@:vue.method
	function onButtonClick():Void {
		js.Browser.alert("Vue.js + Haxe!");
	}
}