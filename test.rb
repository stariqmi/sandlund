require 'rubygems'
require 'mechanize'
require_relative 'submission'

submissions = []

xmls = ["http://www.sec.gov/Archives/edgar/data/1573798/000157379813000002/primary_doc.xml"]

xmls.each do |xml_url|
	mech = Mechanize.new
	xml_doc = mech.get xml_url
	es = EdgarSubmission.new xml_doc
	submissions << es
end

builder = Nokogiri::XML::Builder.new do |xml|
	xml.submissions {
		submissions.each do |sub|
			xml.edgarSubmission
		end
	}
end

nk_xml = Nokogiri::XML::Document.parse builder.to_xml

index = 0
nk_xml.xpath('//edgarSubmission').each do |sub|
	sub.add_child submissions[index].filterPrimaryIssuer
	sub.add_child submissions[index].filterOfferingData
	index += 1
end

result = File.open("result.xml", "w")
result.puts nk_xml.to_xml
result.close()