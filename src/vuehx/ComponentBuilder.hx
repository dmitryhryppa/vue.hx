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

		inline function getMetaContent(expr:ExprDef):Null<String> {
			return switch (expr) {
				case EConst(c): switch (c) {
						case CString(s): s;
						case _: null;
					}
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
			if (field.meta != null) {
				for (meta in field.meta) {
					switch field.kind {
						case FFun(f):
							{
								switch meta.name {
									case ":vue.activated": fieldsToBeGenerated.set("activated", f);
									case ":vue.updated": fieldsToBeGenerated.set("updated", f);
									case ":vue.mounted": fieldsToBeGenerated.set("mounted", f);
								}
							}
						case _:
					}
				}
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
