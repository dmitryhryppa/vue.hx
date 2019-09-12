package vue;

typedef Route = {
	path:String,
	?name:String,
	?component:VueComponentOptions,
	?children:Array<Route>
}
