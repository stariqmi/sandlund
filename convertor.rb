# Importing required modules
require 'nokogiri'
require 'active_support/all'

# Parse the compiled xml file
xml_file = File.open "edgarSubmissions.xml"
xml_root = Nokogiri::XML xml_file	# Convert to Nokogiri XML node
xml_file.close
edgarSubmissions = xml_root.xpath("//edgarSubmission")	# Search for all submissions

# Write all submissions in json to json.txt
json_file = File.open("json.txt", "w")
edgarSubmissions.each do |esub|		# For each submission
	# Write to file after converting xml to json
	json_file.puts Hash.from_xml(esub.to_xml).to_json
end
json_file.close

