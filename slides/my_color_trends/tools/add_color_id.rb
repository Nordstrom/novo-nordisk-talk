#!/usr/bin/env ruby

require 'json'
require 'csv'
require "open-uri"
require 'net/http'

def parse_colors filename
  colors = {}
  CSV.foreach(filename, :headers => true) do |csv|
    colors[csv['name']] = csv['color_id']
  end
  colors
end

data_filename = "../data/user_colors.json"

colors_filename = "x11.csv"

output_filename = "all_user_colors.json"

all_data = JSON.parse(File.open(data_filename,'r').read)
colors = parse_colors(colors_filename)

all_data.each do |user|
  user['colors'].each do |color|
    color_id = colors[color['name']]
    color['color_id'] = color_id
  end
end

File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(all_data.to_json))
end
