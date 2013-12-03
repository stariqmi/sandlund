require 'mechanize'
require_relative 'submission'

mech = Mechanize.new
xml = mech.get "http://www.sec.gov/Archives/edgar/data/1592681/000108503713000176/primary_doc.xml"
es = EdgarSubmission.new xml
puts es.primaryIssuer