require 'mechanize'

class EdgarSubmission

	attr_reader :primaryIssuer

	def initialize xml
		@xml = xml
		@primaryIssuer = getPrimaryIssuerInfo
	end

	def getPrimaryIssuerInfo
		entityName = @xml.search('//primaryIssuer/entityName').text
		stateOrCountry = @xml.search('//primaryIssuer/issuerAddress/stateOrCountry').text
		zipCode = @xml.search('//primaryIssuer/issuerAddress/zipCode').text
		issuerAddress = {state_country: stateOrCountry, zip: zipCode}
		entityType = @xml.search('//primaryIssuer/entityType').text
		yearInfo = @xml.search('//primaryIssuer/yearOfInc/withinFiveYears')
		yearOfInc = if yearInfo.count == 0
			{overFive: true, underFive: false, year: 0}
		else
			{overFive: false, underFive: true, year: @xml.search('//yearOfInc/value').text}
		end
		{entityName: entityName, entityType: entityType, issuerAddress: issuerAddress, yearOfInc: yearOfInc}
	end
end