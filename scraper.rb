require 'mechanize'
require_relative 'submission'

mechanic = Mechanize.new	# Create new Mechanize object 
# Navigate to the source main page
mechanic.get "http://www.sec.gov/cgi-bin/srch-edgar?text=06c&first=2013&last=2013"
puts mechanic.page.title

page = mechanic.page	# Get the html of the main page as a Nokogiri object
data_links = []	# Holder for all relevant links
page_num = 1
while true
	puts "Parsing #{page_num}th page for company links"
	main_table = page.search('/html/body/div[1]/table')	# Get the specific table
	all_links = main_table.css("a")	# Search for all links in the table
	all_links.each do |link|	# Loop through all the links in the above table
		# If it is not a link to the company info as html or txt, add the link to above holder
		data_links << link unless (link.text == "[html]" || link.text == "[text]")
	end

	pagination = mechanic.page.search('/html/body/div[1]/center[1]') # Find html tag that holds the pagination
	nav_links = pagination.css("a") # Find all pagination links
	next_page = nav_links[-1]	# Get the last pagination link on current page
	if (next_page.text == "[NEXT]")	# If next page link exists
		page_num += 1
		mechanic.get next_page["href"] # Get the next page's href
	else	# End of pages
		puts "All pages parsed ... "
		break
	end

end

xml_data = []

base_url = "http://www.sec.gov" # Base Url to append to the relevant company links
data_links.each do |dl|	# Loop through all the relevant links
	link = base_url + dl["href"]	# Create full url using the relevant link href
	mechanic.get link	# Navigate to the newly created url
	xml_link = mechanic.page.link_with(:text => /xml/) # Find the link with the text "xml" in it
	xml_doc = base_url + xml_link.href
	puts "Parsing xml at #{xml_doc}"
	xml = mechanic.get xml_doc
	edgar_sub = EdgarSubmission.new xml
end



