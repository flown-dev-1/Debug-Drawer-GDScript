shader_type spatial;
render_mode unshaded, cull_disabled;

void vertex() {
	if (VERTEX.y > 0.0) {
		VERTEX.xz *= INSTANCE_CUSTOM.r;
	}
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
