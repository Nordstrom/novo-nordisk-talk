#!/usr/bin/env ruby


start_dir = 'comp_styles'

imgs = Dir.glob(start_dir + "/*.jpg")

counts = {}
imgs.each do |img|
  color_id = File.basename(img).split("_")[0]

  if !counts[color_id]
    counts[color_id] = 0
  end

  count = counts[color_id]

  output_filename = "comp_style_imgs/#{color_id}_#{count}.jpg"

  counts[color_id] += 1

  system("cp #{img} #{output_filename}")

end
