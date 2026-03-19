uniform sampler2D texture;

uniform int y1;
uniform int y2;
uniform int x;
uniform int w;
uniform int h;
uniform int x_center;

varying vec2 v_texCoord;

void main()
{
	vec4 frag = texture2D(texture, v_texCoord);

	int x_texel = int(float(w) * v_texCoord.x);
	int y_texel = int(float(h) * (1. - v_texCoord.y));

	if (
		((x < x_center && x_texel < x) || (x > x_center && x_texel >= x))
			&& y_texel >= y1
			&& y_texel < y2
	) {
		frag = vec4(0., 0., 0., 0.);
	}

	gl_FragColor = frag;
}
