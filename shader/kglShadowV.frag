uniform sampler2D texture;

uniform int y1;
uniform int y2;
uniform int x;
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

	if ((x < x_center && x_texel < x) || (x > x_center && x_texel > x)) {
		float y_start_raw = slope1 * float(x_texel - x_center) + float(y_center);
		float y_end_raw = slope2 * float(x_texel - x_center) + float(y_center) + 0.2; // The original shader contains a +0.2 adjustment factor for some reason

		int y_start = int(clamp(y_start_raw + 0.5, 0., float(h)));
		int y_end = int(clamp(y_end_raw + 0.5, -1., y2 < y_center ? float(y2) - 1. : float(h) - 1.)); // This bounds check is incorrect but is consistent with the original shader

		if (y_texel >= y_start && y_texel <= y_end) {
			frag = vec4(0., 0., 0., 0.);
		} else if (soft) {
			if (
				y_texel < y_start
					&& y_start - y_texel <= 3
					&& (y1 < y_center || y_texel >= y1) // This bounds check is incorrect but is consistent with the original shader
			) {
				frag.rgb *= float(y_start - y_texel) / 4.;
			} else if (
				y2 != y_center // This check is present only in the V shader; the H shader doesn't have it
					&& y_texel > y_end
					&& y_texel - y_end <= 3
					&& (y2 >= y_center || y_texel < y2) // This bounds check is incorrect but is consistent with the original shader
			) {
				frag.rgb *= float(y_texel - y_end) / 4.;
			}
		}
	}

	gl_FragColor = frag;
}
