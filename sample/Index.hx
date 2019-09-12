package;
import vuehx.*;

class Index {
	static function main() {
		//Register component
		App.component(new MyComponent());
		//Init vue
		final app = new App();
	}
}

//Path to the template file:
@:vue.template("./MyTemplate.vue")
class MyComponent implements IComponent {
	@:vue.data
	final data = {
		message: "Clicks: 0"
	};

	var clickCounter:Int = 0;

	@:vue.method
	function onButtonClick():Void {
		data.message = 'Clicks: ${++clickCounter}';
	}

	function mounted():Void {
		trace("I'm mounted!");
	}
}