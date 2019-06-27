package vue;

@:native("Vue.http")
extern class VueResource {
	public static function get<T>(url:String, ?options:{}):js.Promise<Result<T>>;
	public static function post<T>(url:String, ?body:{}, ?options:{}):js.Promise<Result<T>>;
}

typedef Result<T> = {
	?data:T
}
