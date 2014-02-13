#!/usr/bin/env ruby

require 'json'
require "open-uri"

files = Dir.glob("data/**/*.json")

OUTPUT_DIR = "img"

def get_file url, size = nil
  if size
    url = url.gsub("Medium", size)
  end
  name = File.basename(url)
  puts name
  File.open(File.join(OUTPUT_DIR,name), 'wb') do |fo|
    fo.write open("#{url}").read
  end
end

files.each do |file|
  puts file
  data = JSON.parse(File.read(file))
  data['colors'].each do |color|
    if color.is_a?(Array)
      color = color[1]
    end
    if color['purchases']
      color['purchases'].each do |purchase|
        url = purchase['image_url']
        get_file(url)
      end
    elsif color['recs']
      color['recs'].each do |rec|
        url = rec['image_url']
        get_file(url, "Thumbnail")
      end
    else
      puts color
    end
  
  end
end
