# Test suite for mkxp-z draw_text.
# Author: Eblo.
# License CC0.
#
# Run the suite via the "postloadScript" field in mkxp.json.
# Use RGSS v3 for best results. Was compared with Enterbrain VX Ace Runtime.

class Scene_Title

  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @sprite1 = Sprite.new
    @sprite1.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    c = 128
    @background = Plane.new
    w = h = 16
    @background.bitmap = Bitmap.new(w, h)
    @background.bitmap.fill_rect(@background.bitmap.rect, Color.new(c, c, c))
    r = Color.new(255, 0, 0)
    @background.bitmap.fill_rect(0, 0, w, 1, r)
    @background.bitmap.fill_rect(0, h - 1, w, 1, r)
    @background.bitmap.fill_rect(0, 0, 1, h, r)
    @background.bitmap.fill_rect(w - 1, 0, 1, h, r)
    @background.z = @sprite1.z - 1
    s = "The quick brown fox jumps over the lazy dog"
    pos = Rect.new(0, 0, @sprite1.width, Graphics.height)
    @sprite1.bitmap.draw_text(pos, s)
    pos.y += 20
    s.each_char do |char|
      size = @sprite1.bitmap.text_size(char)
      @sprite1.bitmap.draw_text(pos, char)
      pos.x += size.width
    end
  end

end
