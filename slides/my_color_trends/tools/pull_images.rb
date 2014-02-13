#!/usr/bin/env ruby

require 'json'
require 'csv'
require "open-uri"
require 'net/http'


BASEURL = "http://g.nordstromimage.com/imagegallery/store/product/Thumbnail/"

input_filename = "comp_color_data.json"

output_dir = 'comp_styles'

input_data = JSON.parse(File.open(input_filename,'r').read)

output_filename = "comp_user_colors.json"

input_data.each do |color_id, color|
  color_id = color_id.to_i
  color['styles'].each do |pur|
    style_id = pur['product_photo_id'].to_i
    style_mod = style_id % 20
    url = "#{BASEURL}/#{style_mod}/_#{style_id}.jpg"
    puts url
    output_filename = "#{output_dir}/#{color_id}_#{style_id}.jpg"

    begin
    File.open(output_filename, 'wb') do |fo|
      fo.write open(url).read
    end
    rescue
    end
  end
end
