require 'yaml'
# merges 747 and 748

target = YAML::load(File.read("predictions/747.yml"))
b =  YAML::load(File.read("predictions/748.yml"))

target['directions'].each do |dir|
  headsign = dir['headsign']
  b_dir = b['directions'].detect {|x| x['headsign'] == headsign}
  if dir['direction_name'] == "Outbound"
    dir['stops'] =   dir['stops']  + b_dir['stops']  
  else
    dir['stops'] =  b_dir['stops']  + dir['stops'] 
  end
end

File.open("predictions/ct2.yml", 'w') {|f| f.puts target.to_yaml}
