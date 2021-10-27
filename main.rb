# frozen_string_literal: true

require "dxruby"
require "ricecream"

BG = ARGV[0] == "bg"

BASE_IMAGE = Image.load("./assets/base.png")
HAND_IMAGE = Image.load("./assets/arms.png")
NEKOMIMI_IMAGE_RAW_L = Image.load("./assets/neko-l.png")
NEKOMIMI_IMAGE_RAW_R = Image.load("./assets/neko-r.png")
over = Image.load("./assets/over.png")

MAIN_TARGET = RenderTarget.new(BASE_IMAGE.width, BASE_IMAGE.height)
MAIN_TARGET.bgcolor = [BG ? 255 : 0, 242, 243, 245]
MASK_SHADER = Shader.new(
  Shader::Core.new(
    File.read("./mask.hlsl"), { mask: :texture }
  )
)
RADIUS = Math.sqrt((BASE_IMAGE.width / 2) ** 2 + (BASE_IMAGE.height / 2) ** 2)

def get_xy(direction)
  radian = Math::PI * (direction / 180.0)
  x = BASE_IMAGE.width / 2 + RADIUS * Math.cos(radian)
  y = BASE_IMAGE.height / 2 - RADIUS * Math.sin(radian)
  [x, y]
end

min_x_l = 100000
min_y_l = 10000
max_x_l = 0
max_y_l = 0

(0...NEKOMIMI_IMAGE_RAW_L.width).to_a.product((0...NEKOMIMI_IMAGE_RAW_L.height).to_a) do |x, y|
  next unless NEKOMIMI_IMAGE_RAW_L[x, y][0] == 255

  min_x_l = x if min_x_l > x
  min_y_l = y if min_y_l > y
  max_x_l = x if max_x_l < x
  max_y_l = y if max_y_l < y
end

NEKOMIMI_IMAGE_L = NEKOMIMI_IMAGE_RAW_L.slice(min_x_l, min_y_l, max_x_l - min_x_l + 1, max_y_l - min_y_l + 1)

min_x_r = 10000
min_y_r = 10000
max_x_r = 0
max_y_r = 0

(0...NEKOMIMI_IMAGE_RAW_R.width).to_a.product((0...NEKOMIMI_IMAGE_RAW_R.height).to_a) do |x, y|
  next unless NEKOMIMI_IMAGE_RAW_R[x, y][0] == 255

  min_x_r = x if min_x_r > x
  min_y_r = y if min_y_r > y
  max_x_r = x if max_x_r < x
  max_y_r = y if max_y_r < y
end

NEKOMIMI_IMAGE_R = NEKOMIMI_IMAGE_RAW_R.slice(min_x_r, min_y_r, max_x_r - min_x_r + 1, max_y_r - min_y_r + 1)

Dir.glob("./#{BG ? "frames_bg" : "frames"}/*.png").each { |f| File.unlink(f) }
range = 40
diff = 2
count = (range * 2 + 1)
(0...count).each.with_index do |r, index|
  # i = (r - range) / mod
  i = Math.sin((Math::PI * 2) * (r / count.to_f)) * diff
  offset = ((i + diff) * 2).round
  MAIN_TARGET.draw(0, offset, BASE_IMAGE)
  MAIN_TARGET.draw(0, 0, HAND_IMAGE)
  x, y = get_xy(45 - i)
  # ic x, y, min_x_r, min_y_r, max_x_r, max_y_r
  MAIN_TARGET.draw_morph(
    (BASE_IMAGE.width - x) + min_x_r, y + min_y_r + offset,
    # min_x_r, min_y_r + offset,
    max_x_r, min_y_r + offset,
    max_x_r, max_y_r + offset,
    min_x_r, max_y_r + offset,
    NEKOMIMI_IMAGE_R
  )
  MAIN_TARGET.draw_morph(
    min_x_l, min_y_l + offset,
    (x - (BASE_IMAGE.width - max_x_l)), y + min_y_l + offset,
    max_x_l, max_y_l + offset,
    min_x_l, max_y_l + offset,
    NEKOMIMI_IMAGE_L
  )
  MAIN_TARGET.draw(0, offset, over)
  MAIN_TARGET.to_image.save("./#{BG ? "frames_bg" : "frames"}/#{index.to_s.rjust(2, "0")}.png")
  MAIN_TARGET.update
end

# `python png2gif.py`
