package vue;

typedef VueComponentOptions = {
	?data:() -> Any,
	?props:Array<String>,
	?propsData:Dynamic,
	?computed:Dynamic,
	?methods:Dynamic,
	?template:String,
	?watch:Dynamic,
	?activated:() -> Void,
	?updated:() -> Void,
	?mounted:() -> Void
}
