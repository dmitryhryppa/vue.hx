package vue;

import js.lib.Promise;

@:native("Vue.http")
extern class VueResource {
	public static function get<T>(url:String, ?options:{}):Promise<Result<T>>;
	public static function post<T>(url:String, ?body:{}, ?options:{}):Promise<Result<T>>;
}

typedef Result<T> = {
	?data:T
}
