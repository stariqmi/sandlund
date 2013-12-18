# Import required modules
require 'mechanize'
require 'yaml'
require_relative 'submission'

mechanic = Mechanize.new	# Create new Mechanize object

# Proxy
# mechanic = Mechanize.new do|a|
#   a.set_proxy('proxy', 8080, 'i840192', 'hckg:stm18092')
#   a.user_agent_alias = "Windows IE 6"
# end

# Navigate to the source main page
mechanic.get "http://www.sec.gov/cgi-bin/srch-edgar?text=06c&first=2013&last=2013"
puts mechanic.page.title

page = mechanic.page	# Get the html of the main page as a Nokogiri object
base_url = "http://www.sec.gov" # Base Url to append to the relevant company links
data_links = []	# Holder for all relevant links
source_links = []	# Holder for all source links
html_links = []	# Holder for all html links
sub_types = []	
companies = []	# Holder for all companies scraped
page_num = 1

links_file = File.open('links.txt', 'w')	# File that holds all company names and their links

while true
	puts "Parsing #{page_num}th page for company links"
	main_table = mechanic.page.search('/html/body/div[1]/table')	# Get the specific table
	all_links = main_table.css("a")	# Search for all links in the table
	all_links.each do |link|	# Loop through all the links in the above table
		# If it is not a link to the company info as html or txt
		if not (link.text == "[html]" || link.text == "[text]")
			data_links << link 	# Add the link to above holder(data_links)
			links_file.puts "#{link.text} --- #{base_url + link['href']}" # Write to links.txt
		end
	end

	pagination = mechanic.page.search('/html/body/div[1]/center[1]') # Find html tag that holds the pagination
	nav_links = pagination.css("a") # Find all pagination links
	next_page = nav_links[-1]	# Get the last pagination link on current page
	if (next_page.text == "[NEXT]")	# If next page link exists
		# break if page_num == 5 # Code for TESTING, remove in production environment
		page_num += 1
		mechanic.get next_page["href"] # Get the next page's href
	else	# End of pages
		puts "All pages parsed ... "
		break
	end
end

links_file.close()

submissions = []
# Export companies from YAML as an array
existing_companies = YAML.load(File.open("companies.yml")) || []

data_links.each do |dl|	# Loop through all the relevant links
	# Check if Company is not already in the yaml document (Prevents duplicates)
	if not existing_companies.include? dl.text
		puts "New Company: #{dl.text}"
		link = base_url + dl["href"]	# Create full url using the relevant link href
		mechanic.get link	# Navigate to the newly created url
		xml_link = mechanic.page.link_with(:text => /xml/) # Find the link with the text "xml" in it
		html_link = mechanic.page.link_with(:text => /html/) # Find the link with the text "html" in it
		xml_doc = base_url + xml_link.href	# Create full url to xml document
		html_doc = base_url + html_link.href # Create full url to html document
		html_links << html_doc # Add link to html_links holder
		puts "Parsing xml at #{xml_doc}"	
		raw_xml = mechanic.get xml_doc	# Navigate to xml document url
		sub_types << raw_xml.search("//submissionType")
		edgar_sub = EdgarSubmission.new raw_xml	# Create an EdgarSubmission object from the xml retrieved above
		existing_companies << dl.text	# Add link text(company name) to existing companies
		submissions << edgar_sub	# Add the object to submission array
		source_links << link # Add link to source_links holder
	end
end

# Export all exisiting companies to YAML document
comp_file = File.open("companies.yml", "w")
comp_file.write(existing_companies.to_yaml)
comp_file.close


index = 0
# Result xml creation using Nokogiri
builder = Nokogiri::XML::Builder.new do |xml|
	xml.documentRoot {
		submissions.each do |sub|
			# Create edgarSubmission tag
			xml.edgarSubmission {
				xml.submissionType sub_types[index][0].content	# From sub_types
				xml.sourceLink source_links[index]				# From source_links
				xml.htmlDocLink html_links[index]				# From html_links
				index += 1
			}
		end
	}
end

# Parse above generated xml
nk_xml = Nokogiri::XML::Document.parse builder.to_xml

index = 0

# For each edgarSubmission tag
nk_xml.xpath('//edgarSubmission').each do |sub|
	sub.add_child submissions[index].getSubmissionType		# Add submissionType as child tag
	sub.add_child submissions[index].filterPrimaryIssuer	# Add primaryIssue as child tag
	sub.add_child submissions[index].filterOfferingData		# Add offeringData as child tag
	index += 1
end

# Write xml to XML document as result
result = File.open("edgarSubmissions.xml", "w")
result.puts nk_xml.to_xml
result.close()

# Compiling master list
master_xml = Nokogiri::XML::Document.parse File.open("master.xml")
master_root = master_xml.root
nk_xml.xpath('//edgarSubmission').each do |sub|
	master_root.add_child sub
end
master = File.open("master.xml", "w")
master.puts master_xml.to_xml
master.close()