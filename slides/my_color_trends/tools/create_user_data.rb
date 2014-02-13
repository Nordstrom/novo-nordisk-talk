#!/usr/bin/env ruby

require 'json'
require 'csv'

require 'time'

# input_filename = "color_transactions_no_undies.tsv"
input_filename = "transactions.tsv"
# input_filename = "test.tsv"

output_dir = "../data/color_data"

users = {}

BAD = ["Bra"]

def clean_name name
  name.gsub(/\(.*\)/,"").strip()
end

def pull_out_color csv
  rgb = csv["rgb"].gsub("{","").gsub("}","").split(",").collect {|c| c.to_i}
  rgb_string = "rgb(#{rgb.join(",")})"
  grayscale = csv["grayscale"] == "True"
  col = {"name" => clean_name(csv["color_name"]), "color_id" => csv["color_id"], "rgb" => rgb, "rgb_string" => rgb_string, "grayscale" => grayscale, "purchases" => []}
  col
end

def add_purchase color, csv
  # puts csv["BUS.DT"].strip
  # month/day/year
  date_parts = csv["BUS.DT"].strip.split("/").collect {|s| s.to_i}
  pur = {"sku_key" => csv["sku_idnt"].strip, "gender" => csv["gender.x"].strip, "style_id" => csv["web_style_id"].strip,
         "product_url" => csv["product_url"], "image_url" => csv["image_url"], 
         "description" => csv["description"].strip,
         "subclass_id" => csv["subclassifier_id"],
         "class_id" => csv["classifier_id"],
         "age_group" => csv["age_group"],
         # "purchase_date" => Date.parse(csv["BUS.DT"].strip),
         # "purchase_date" => DateTime.strptime(csv["BUS.DT"].strip, '%-m/%-d/%Y'),
         "purchase_date" => Date.new(date_parts[2], date_parts[0], date_parts[1]),
         "percent_color" => csv["color_percent"].strip.to_f
  }
  # if !BAD.include?(pur["description"])
    color['purchases'] << pur
  # end
end

def weight color
  color["grayscale"] == "t" ? 0.2 : 1.0
end

def process_color color, total_purchases, total_colors
  purchase_count = color['purchases'].length
  percent_sum = color['purchases'].inject(0) {|sum, col| sum + (col['percent_color'] * weight(color))}

  color['count'] = purchase_count
  color['color_per_purchaes'] = ((purchase_count / total_purchases.to_f)).round(4)
  color['weighted_count'] = percent_sum
  color['percent'] = ((purchase_count / total_purchases.to_f) * 100.0).round(4)

  color
end

def process_user user
  processed_colors = []
  total_user_purchases = user['colors'].values.inject(0) {|sum, col| sum + col['purchases'].length}
  min_date = user['colors'].values.collect {|col| col['purchases'].collect {|p| p['purchase_date']}.min}.min
  max_date = user['colors'].values.collect {|col| col['purchases'].collect {|p| p['purchase_date']}.max}.max
  total_colors = user['colors'].length

  user["start_date"] = min_date
  user["end_date"] = max_date
  user["total_purchases"] = total_user_purchases
  user["total_colors"] = total_colors

  puts total_user_purchases
  user['colors'].each do |color_name, color|
    p_color = process_color(color, total_user_purchases, total_colors)
    processed_colors << p_color
  end
  user['colors'] = processed_colors.sort {|a,b| b['count'] <=> a['count']}
  user
end


CSV.foreach(input_filename, { :col_sep => "\t", :headers => true }) do |csv|
  color_id = clean_name(csv["color_name"])
  keep = csv["grayscale"] == "f"
  if !keep
    next
  end
  if !users[csv["CUST_KEY"]]
    users[csv["CUST_KEY"]] = {"id" => csv["CUST_KEY"], "first_name" => csv["FIRST"], "last_name" =>csv["LAST"],"gender" => csv['sex'],"colors" => {}}
  end
  if !users[csv["CUST_KEY"]]["colors"][color_id]
    users[csv["CUST_KEY"]]["colors"][color_id] = pull_out_color(csv)
  end

  add_purchase(users[csv["CUST_KEY"]]["colors"][color_id], csv)
end

puts users.keys.size

processed = []

all = []
users.each do |user_id, user_data|
  p_user = process_user(user_data)
  all << {"id" => user_id, "first_name" => p_user["first_name"], "last_name" => p_user["last_name"]}
  processed << p_user
end

system("mkdir -p #{output_dir}")

processed.each do |user_data|
  user_id = user_data['id']
  output_filename = File.join(output_dir, "#{user_id}.json")
  File.open(output_filename, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(user_data.to_json))
  end
end

all_filename = File.join(output_dir, "all.json")
File.open(all_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(all.to_json))
end
