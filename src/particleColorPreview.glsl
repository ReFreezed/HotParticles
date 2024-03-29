uniform vec4 colors[8];
uniform int  colorCount;

int clampInt(int v, int low, int high) {
	if (v < low )  return low;
	if (v > high)  return high;
	return v;
}

vec4 effect(vec4 loveColor, Image tex, vec2 posInTex, vec2 posOnCanvasPx) {
	// Solid color on the left.
	if (posInTex.x < 1/6.) {
		float iFloat = float(colorCount) * posInTex.y;
		int   i      = int(iFloat);
		return colors[clampInt(i, 0, colorCount-1)];

	// Gradient on the right.
	} else {
		float iFloat = float(colorCount-1) * posInTex.y;
		int   i1     = int(iFloat);
		vec4  color1 = colors[clampInt(i1,   0, colorCount-1)];
		vec4  color2 = colors[clampInt(i1+1, 0, colorCount-1)];
		return mix(color1, color2, fract(iFloat));
	}
}
