# Test suite for mkxp-z draw_text.
# Copyright 2025 Splendide Imaginarius.
# License LGPLv2+.
#
# Run the suite via the "customScript" field in mkxp.json.
# Use RGSS v2 for best results. Was compared with Enterbrain VX Runtime.

def dump(bmp, spr, desc)
	spr.bitmap = bmp
	Graphics.wait(1 * 60)

	# Comment out these 2 lines for Enterbrain runtime
	bmp.to_file("test-results/" + desc + ".png")
	System::puts("Finished " + desc)
end

# Setup graphics
Graphics.resize_screen(640, 480)

# Setup font
fnt = Font.new("Liberation Sans", 72)

# Setup splash screen
bmp = Bitmap.new(640, 480)
bmp.fill_rect(0, 0, 640, 480, Color.new(0, 0, 0))

bmp.font = fnt
bmp.draw_text(0, 0, 640, 240, "draw_text Test Suite", 1)
bmp.draw_text(0, 240, 640, 240, "Starting Now", 1)

spr = Sprite.new()
spr.bitmap = bmp

Graphics.wait(1 * 60)

# Tests start here

bmp = Bitmap.new(640, 480)
bmp.fill_rect(0, 0, 640, 480, Color.new(0, 0, 0))
bmp.draw_text(0, 0, 640, 240, "Forwards", 1)
bmp.draw_text(0, 240, 640, 240, "Forwards", 1)
dump(bmp, spr, "forwards")

bmp = Bitmap.new(640, 480)
bmp.fill_rect(0, 0, 640, 480, Color.new(0, 0, 0))
bmp.draw_text(0, 0, 640, 240, "Negative Width", 1)
bmp.draw_text(640, 240, -640, 240, "Negative Width", 1)
dump(bmp, spr, "negative-width")

bmp = Bitmap.new(640, 480)
bmp.fill_rect(0, 0, 640, 480, Color.new(0, 0, 0))
bmp.draw_text(0, 0, 640, 240, "Negative Height", 1)
bmp.draw_text(0, 480, 640, -240, "Negative Height", 1)
dump(bmp, spr, "negative-height")

# Tests are finished, show exit screen

bmp = Bitmap.new(640, 480)
bmp.fill_rect(0, 0, 640, 480, Color.new(0, 0, 0))

bmp.font = fnt
bmp.draw_text(0, 0, 640, 240, "draw_text Test Suite", 1)
bmp.draw_text(0, 240, 640, 240, "Has Finished", 1)
spr.bitmap = bmp

Graphics.wait(1 * 60)

exit
