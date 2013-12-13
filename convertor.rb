require 'nokogiri'
require 'active_support/all'

xml_file = File.open "edgarSubmissions.xml"
xml_root = Nokogiri::XML xml_file
xml_file.close
edgarSubmissions = xml_root.xpath("//edgarSubmission")

json_file = File.open("json.txt", "w")
edgarSubmissions.each do |esub|
	json_file.puts Hash.from_xml(esub.to_xml).to_json
end
json_file.close

