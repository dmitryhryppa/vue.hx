package vuehx;

import haxe.ds.StringMap;
import haxe.macro.PositionTools;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;

/*
	Created at: 07 March 2019
	[Description]
 */
class ComponentBuilder {
	public static function build():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		final pos:Position = Context.currentPos();
		final c:ClassType = Context.getLocalClass().get();
		var vueCompFields:Array<ObjectField> = [];
		fields.push({
			name: "__name",
			access: [APublic, AFinal],
			kind: FVar(macro:String, {
				expr: EConst(CString((~/([^_A-Z])([A-Z])/g).replace(c.name, "$1-$2").toLowerCase())),
				pos: pos
			}),
			meta: [{name: ":noCompletion", pos: pos}],
			pos: pos
		});

		inline function getMetaContent(expr:ExprDef):Null<String> {
			return switch (expr) {
				case EConst(CString(s)): s;
				case _: null;
			}
		};

		for (entry in c.meta.get()) {
			if (entry.params.length > 0) {
				switch (entry.name) {
					case ":vue.props":
						{
							if (entry.params != null) {
								vueCompFields.push({
									field: "props",
									expr: {
										expr: EBlock(entry.params),
										pos: pos
									}
								});
							}
						}
					case ":vue.template":
						{
							final v:Null<String> = getMetaContent(entry.params[0].expr);
							if (v != null) {
								vueCompFields.push(parseTemplate(v, fields));
							}
						}
				}
			}
		}

		vueCompFields.push({
			field: "data",
			expr: {
				expr: EFunction(null, {
					args: [],
					ret: TPath({pack: [], name: "Dynamic"}),
					expr: {
						expr: EReturn({
							expr: EObjectDecl(genData(pos, fields)),
							pos: pos
						}),
						pos: pos
					}
				}),
				pos: pos
			}
		});

		vueCompFields.push({
			field: "methods",
			expr: {
				expr: EObjectDecl(genMethods(pos, fields)),
				pos: pos
			}
		});

		vueCompFields.push({
			field: "computed",
			expr: {
				expr: EObjectDecl(genComputed(pos, fields)),
				pos: pos
			}
		});

		vueCompFields = vueCompFields.concat(genLifecycleMethods(pos, fields));

		final toVue:Field = {
			name: "asComponent",
			doc: '',
			access: [APublic, AInline],
			pos: pos,
			kind: FFun({
				args: [],
				ret: TPath({pack: ["vue"], name: "VueComponentOptions"}),
				expr: {
					expr: EReturn({
						expr: EObjectDecl(vueCompFields),
						pos: pos
					}),
					pos: pos
				}
			})
		};
		fields.push(toVue);

		return fields;
	}

	static function genLifecycleMethods(pos:Position, fields:Array<Field>):Array<ObjectField> {
		final fieldsToBeGenerated:StringMap<Function> = new StringMap();
		for (field in fields) {
			switch field.kind {
				case FFun(f):
					switch field.name {
						case "activated":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called when a kept-alive component is activated.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "beforeCreate":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called synchronously immediately after the instance has been initialized, before data observation and event/watcher setup.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "created":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called synchronously after the instance is created. At this stage, the instance has finished processing the options which means the following have been set up: data observation, computed properties, methods, watch/event callbacks. However, the mounting phase has not been started, and the `$el` property will not be available yet.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "beforeUpdate":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called when data changes, before the DOM is patched. This is a good place to access the existing DOM before an update, e.g. to remove manually added event listeners.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "updated":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called after a data change causes the virtual DOM to be re-rendered and patched.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "beforeMount":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called right before the mounting begins: the `render` function is about to be called for the first time.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "mounted":
							field.doc = "Called after the instance has been mounted, where `el` is replaced by the newly created `vm.$el`. If the root instance is mounted to an in-document element, `vm.$el` will also be in-document when `mounted` is called.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
							fieldsToBeGenerated.set(field.name, f);
						case "beforeDestroy":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called right before a Vue instance is destroyed. At this stage the instance is still fully functional.\n\r**This hook is not called during server-side rendering.**\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "destroyed":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called after a Vue instance has been destroyed. When this hook is called, all directives of the Vue instance have been unbound, all event listeners have been removed, and all child Vue instances have also been destroyed.\n\r**This hook is not called during server-side rendering.**\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
						case "errorCaptured":
							fieldsToBeGenerated.set(field.name, f);
							field.doc = "Called when an error from any descendent component is captured. The hook receives three arguments: the error, the component instance that triggered the error, and a string containing information on where the error was captured. The hook can return `false` to stop the error from propagating further.\n\rSee also: https://vuejs.org/v2/guide/instance.html#Lifecycle-Diagram";
					}
				case _:
			}
		}

		final objFields:Array<ObjectField> = [];
		for (name => f in fieldsToBeGenerated) {
			objFields.push({
				field: name,
				expr: {
					expr: EFunction(null, f),
					pos: pos
				}
			});
		}

		// Gen constructor if it is not exists
		var constructorExists:Bool = false;
		for (field in fields) {
			if (field.name == "new") {
				constructorExists = true;
				break;
			}
		}
		if (!constructorExists) {
			fields.push({
				name: "new",
				access: [APublic],
				kind: FFun({
					args: [],
					ret: null,
					expr: {
						expr: EBlock([]),
						pos: pos
					}
				}),
				pos: pos
			});
		}
		return objFields;
	}

	static function genComputed(pos:Position, fields:Array<Field>):Array<ObjectField> {
		final objFields:Array<ObjectField> = [];
		for (field in fields) {
			if (field.meta != null) {
				for (meta in field.meta) {
					if (meta.name == ":vue.computed") {
						switch field.kind {
							case FVar(t, e):
							case FProp(get, set, t, e):
								final getsetFields:Array<ObjectField> = [];

								final getObjectField:Null<ObjectField> = switch (get) {
									case "never": null;
									default: {
											field: "get",
											expr: {
												expr: EFunction(null, {
													args: [],
													ret: t,
													expr: {
														expr: EReturn({
															expr: EConst(CIdent(field.name)),
															pos: pos
														}),
														pos: pos
													}
												}),
												pos: pos
											}
										}
								};

								final setObjectField:Null<ObjectField> = switch (set) {
									case "never": null;
									default: {
											field: "set",
											expr: {
												expr: EFunction(null, {
													args: [{name: "v", type: t}],
													ret: t,
													expr: {
														expr: EReturn({
															expr: EBinop(OpAssign, {
																expr: EConst(CIdent(field.name)),
																pos: pos
															}, {
																expr: EConst(CIdent("v")),
																pos: pos
															}),
															pos: pos
														}),
														pos: pos
													}
												}),
												pos: pos
											}
										}
								};

								if (getObjectField != null) {
									getsetFields.push(getObjectField);
								}
								if (setObjectField != null) {
									getsetFields.push(setObjectField);
								}

								objFields.push({
									field: field.name,
									expr: {
										expr: EObjectDecl(getsetFields),
										pos: pos
									}
								});
							case _:
						}
					}
				}
			}
		}
		return objFields;
	}

	static function genData(pos:Position, fields:Array<Field>):Array<ObjectField> {
		final objFields:Array<ObjectField> = [];
		for (field in fields) {
			if (field.meta != null) {
				for (meta in field.meta) {
					if (meta.name == ":vue.data") {
						switch field.kind {
							case FVar(t, e):
								{
									objFields.push({
										field: field.name,
										expr: {
											expr: EField({
												expr: EConst(CIdent("this")),
												pos: pos
											}, field.name),
											pos: pos
										}
									});
								}
							case _:
						}
					}
				}
			}
		}

		return objFields;
	}

	static function genMethods(pos:Position, fields:Array<Field>):Array<ObjectField> {
		final objFields:Array<ObjectField> = [];
		for (field in fields) {
			if (field.meta != null) {
				for (meta in field.meta) {
					if (meta.name == ":vue.method") {
						switch field.kind {
							case FFun(f):
								{
									objFields.push({
										field: field.name,
										expr: {
											expr: EField({
												expr: EConst(CIdent("this")),
												pos: pos
											}, field.name),
											pos: pos
										}
									});
								}
							case _:
						}
					}
				}
			}
		}

		return objFields;
	}

	static function genRoute(route:String):Void {
		// trace(route);
	}

	static function parseTemplate(template:String, fields:Array<Field>):ObjectField {
		inline function getMatches(ereg:EReg, input:String, index:Int = 0):Array<String> {
			final matches:Array<String> = [];
			while (ereg.match(input)) {
				matches.push(ereg.matched(index));
				input = ereg.matchedRight();
			}
			return matches;
		}

		final vueContent:String = sys.io.File.getContent(template);
		final vars:Array<String> = getMatches(~/\{([^{}]+)\}/g, vueContent);

		/*for (v in vars) {
			final name:String = v.substring(1, v.length - 1);
			var declared:Bool = false;
			for (field in fields) {
				if (field.name == name) {
					declared = true;
				}
			}
			if (!declared) {
				Context.error('$v variable is used in template, but not declared in the parent class.', Context.currentPos());
			}
		}*/

		final startTemplateIndex:Int = vueContent.indexOf("<template>") + 10;
		final endTemplateIndex:Int = vueContent.indexOf("</template>");
		final templateContent = vueContent.substring(startTemplateIndex, endTemplateIndex);

		final templateExpr:Expr = macro $v{templateContent};
		fields.push({
			name: "template",
			access: [APublic],
			kind: FVar(macro:String, templateExpr),
			pos: Context.currentPos()
		});

		final startStyleIndex:Int = vueContent.indexOf("<style>") + 7;
		final endStyleIndex:Int = vueContent.indexOf("</style>");
		final styleContent = vueContent.substring(startStyleIndex, endStyleIndex);

		return {
			field: "template",
			expr: templateExpr
		};
	}
}
