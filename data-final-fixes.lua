-- Static and animated sprites share the same canvas and ground anchor.
local absorber = data.raw.reactor["pollution-absorber"]
absorber.picture = {layers={{
  filename="__pollution-absorber-improved__/graphics/pollution-absorber.png",
  width=256,height=256,scale=0.4,shift={0,0}
}}}
absorber.working_light_picture = {
  filename="__pollution-absorber-improved__/graphics/pollution-absorber-fan.png",
  width=256,height=256,frame_count=24,line_length=4,
  animation_speed=0.5,scale=0.4,shift={0,0},blend_mode="normal",draw_as_glow=false
}
for _,prototype in ipairs({absorber,data.raw.item["pollution-absorber"],data.raw.recipe["pollution-absorber"]}) do
  prototype.icons=nil
  prototype.icon="__pollution-absorber-improved__/graphics/pollution-absorber-icon.png"
  prototype.icon_size=64
end
