-- The custom condenser sprite uses the original three-tile footprint.
local absorber = data.raw.reactor["pollution-absorber"]
absorber.picture = {layers={{
  filename="__pollution-absorber-improved__/graphics/pollution-absorber.png",
  width=512,height=512,scale=0.25,shift=util.by_pixel(0,-24)
}}}
absorber.working_light_picture = {
  filename="__pollution-absorber-improved__/graphics/pollution-absorber-fan.png",
  width=320,height=224,frame_count=24,line_length=4,
  animation_speed=0.5,scale=0.25,shift=util.by_pixel(0,-46)
}
for _,prototype in ipairs({absorber,data.raw.item["pollution-absorber"],data.raw.recipe["pollution-absorber"]}) do
  prototype.icons=nil
  prototype.icon="__pollution-absorber-improved__/graphics/pollution-absorber-icon.png"
  prototype.icon_size=64
end
