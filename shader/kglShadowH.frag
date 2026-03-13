uniform sampler2D texture;

uniform int x1;
uniform int x2;
uniform int y;
uniform bool soft;
uniform int w;
uniform int h;
uniform int x_center;
uniform int y_center;
uniform float slope1;
uniform float slope2;

varying vec2 v_texCoord;

void main()
{
	vec4 frag = texture2D(texture, v_texCoord);

	int x_texel = int(float(w) * v_texCoord.x);
	int y_texel = int(float(h) * (1. - v_texCoord.y));

	if ((y < y_center && y_texel < y) || (y > y_center && y_texel > y)) {
		float x_start_raw = slope1 * float(y_texel - y_center) + float(x_center);
		float x_end_raw = slope2 * float(y_texel - y_center) + float(x_center) + 0.2; // The original shader contains a +0.2 adjustment factor for some reason

		int x_start = int(clamp(x_start_raw + 0.5, 0., float(w)));
		int x_end = int(clamp(x_end_raw + 0.5, -1., x2 < x_center ? float(x2) - 1. : float(w) - 1.)); // This bounds check is incorrect but is consistent with the original shader

		if (x_texel >= x_start && x_texel <= x_end) {
			frag = vec4(0., 0., 0., 0.);
		} else if (soft) {
			if (
				x_texel < x_start
					&& x_start - x_texel <= 3
					&& (x1 < x_center || x_texel >= x1) // This bounds check is incorrect but is consistent with the original shader
			) {
				frag.rgb *= float(x_start - x_texel) / 4.;
			} else if (
				x_texel > x_end
					&& x_texel - x_end <= 3
					&& (x2 >= x_center || x_texel < x2) // This bounds check is incorrect but is consistent with the original shader
			) {
				frag.rgb *= float(x_texel - x_end) / 4.;
			}
		}
	}

	gl_FragColor = frag;
}
