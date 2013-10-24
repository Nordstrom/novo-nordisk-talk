#!/usr/bin/env ruby

require 'json'
require 'csv'
require "open-uri"
require 'net/http'

baseurl = "http://g.nordstromimage.com/imagegallery/store/product/Thumbnail/"

COLOR_BASEURL = "http://color-analytics-service.herokuapp.com/api/top-color-styles/"
COLOR_ENDING = "&epoch=1372636800&reg=laoc"

data_filename = "../data/user_colors.json"

colors_filename = "x11.csv"

all_data = JSON.parse(File.open(data_filename,'r').read)

user_id = '10181881329'

def parse_colors filename
  colors = {}
  CSV.foreach(filename, :headers => true) do |csv|
    colors[csv['name']] = csv['color_id']
  end
  colors
end

def get_color_data color_id
  url = COLOR_BASEURL + color_id + "?color_id=#{color_id}" + COLOR_ENDING
  puts url
  resp = Net::HTTP.get_response(URI.parse(url))
  buffer = resp.body
  result = JSON.parse(buffer)
  result
end

user_data = all_data.select {|u| u['id'] == user_id}[0]

colors = parse_colors(colors_filename)

puts colors.size

color_styles = {}

user_data['complementary_colors'].each do |color|
  # puts color['name']
  color_id = color['id']
  if color_id == '129'
    color_id = '57'
  end

  color_styles[color_id] = get_color_data color_id

end

output_filename = "comp_color_data.json"

File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(color_styles.to_json))
end
