package vue;

typedef VueComponentOptions = {
	?data:() -> Any,
	?props:Array<String>,
	?propsData:Dynamic,
	?computed:Dynamic,
	?methods:Dynamic,
	?template:String,
	?watch:Dynamic,
	?beforeCreate:() -> Void,
	?created:() -> Void,
	?beforeMount:() -> Void,
	?mounted:() -> Void,
	?beforeUpdate:() -> Void,
	?updated:() -> Void,
	?activated:() -> Void,
	?beforeDestroy:() -> Void,
	?destroyed:() -> Void
}
