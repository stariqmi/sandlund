require 'nokogiri'
require 'active_support/all'
require 'firebase'

xml_file = File.open "edgarSubmissions.xml"
xml_root = Nokogiri::XML xml_file
xml_file.close
edgarSubmissions = xml_root.xpath("//edgarSubmission")

edgarSubmissions.each do |esub|
	puts Hash.from_xml(esub.to_xml).inspect
end

es = Hash.from_xml(edgarSubmissions[0].to_xml)

firebase_uri = "http://thecrowdcafe.firebaseio.com"
firebase_io = Firebase.new firebase_uri
response = firebase_io.push("edgar_submission", es)
puts response.code