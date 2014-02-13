#!/usr/bin/env ruby

require 'json'
require 'csv'

require 'time'

# input_filename = "test_male_recs.txt"
# input_filename = "male_recs.txt"
# input_filename = "male_comp_recs_20_clusters.txt"
input_filename = "male_comp_recs.txt"
input_filename = "female_comp_recs_missing.tsv"
# input_filename = "female_comp_recs.txt"
# input_filename = "test.tsv"

output_dir = "../data/recs_comp_data"
system("mkdir -p #{output_dir}")

def clean_name name
  name.gsub(/\(.*\)/,"").strip()
end

def pull_out_color csv
  col = {"color_name" => clean_name(csv["recs.color_name"]), "color_id" => csv["recs.color_id"], 'recs' => []}
  col
end

def add_rec color, csv
  pur = {"style_id" => csv["recs.STYLE.ID"].strip,
         "product_url" => csv["recs.HOSTED.URL"], "image_url" => csv["recs.SKU.IMAGE.URL"].gsub("thumbnail", "Medium"), "web_url" => csv["recs.HOSTED.URL"]
  }

  color['recs'] << pur
end

def weight color
  color["grayscale"] ? 0.2 : 1.0
end

users = {}

CSV.foreach(input_filename, { :col_sep => "\t", :headers => true }) do |csv|
  color_id = csv["color_id"]

  if !users[csv["CUST_KEY"]]
    users[csv["CUST_KEY"]] = {"id" => csv["CUST_KEY"], "colors" => {}}
    puts csv["CUST_KEY"]
  end

  if !users[csv["CUST_KEY"]]["colors"][color_id]
    users[csv["CUST_KEY"]]["colors"][color_id] = pull_out_color(csv)
    puts color_id
  end

  if users[csv["CUST_KEY"]]["colors"][color_id]['recs'].length < 20
    add_rec(users[csv["CUST_KEY"]]["colors"][color_id], csv)
  end
end

users.each do |user_key, user_data|
  user_id = user_data['id']
  output_filename = File.join(output_dir, "#{user_id}.json")
  File.open(output_filename, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(user_data.to_json))
  end
end

# all_filename = File.join(output_dir, "all.json")
# File.open(all_filename, 'w') do |file|
#   file.puts JSON.pretty_generate(JSON.parse(all.to_json))
# end
