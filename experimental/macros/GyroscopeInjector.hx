package macros;

#if macro
#if BMC_GYROSCOPE
import mobile.Gyroscope;
import haxe.macro.Context;
import haxe.macro.Expr;

class GyroscopeInjector {
	public static macro function build():Array<Field> {
		var fields = Context.getBuildFields();

		var hasGyroscope = false;
		for (field in fields) {
			if (field.name == "gyroscope") {
				hasGyroscope = true;
				break;
			}
		}

		if (!hasGyroscope) {
			var gyroVariable = macro :Gyroscope;
			fields.push({
				name: "gyroscope",
				access: [APublic, AStatic],
				kind: FVar(gyroVariable, null),
				pos: Context.currentPos()
			});
			Context.info("Gyroscope static variable added to FlxG", Context.currentPos());
		}

		for (field in fields) {
			if (field.name == "init") {
				switch (field.kind) {
					case FFun(f):
						macro f.expr = macro {
							gyroscope = new Gyroscope();
							${f.expr};
						};
						Context.info("Gyroscope initialization injected into FlxG.init()", Context.currentPos());
					default:
				}
			}
		}

		return fields;
	}
}
#end
#end