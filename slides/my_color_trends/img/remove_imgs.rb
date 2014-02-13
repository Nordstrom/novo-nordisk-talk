#!/usr/bin/env ruby

imgs = Dir.glob('style_imgs/*.jpg')
to_delete = []
imgs.each do |img|
  name = File.basename(img)
  if name.split(".")[0][-1] == "_"
    to_delete << img
  else
    if name.split("_")[1].to_i > 5
      to_delete << img
    end
  end

end

to_delete.each do |del|
  puts del
  system("rm #{del}")
end
