require 'mechanize'

class EdgarSubmission

	
	def initialize xml
		@xml = xml
	end

	def filterPrimaryIssuer
		primary_issuer = @xml.search '//primaryIssuer'
		
		current = File.open("currently_parsing.xml", "w")
		current.puts primary_issuer
		current.close()

		primary_issuer.at_xpath('//schemaVersion').remove
		primary_issuer.at_xpath('//submissionType').remove
		primary_issuer.at_xpath('//testOrLive').remove
		primary_issuer.at_xpath('//cik').remove
		primary_issuer.at_xpath('//street1').remove
		primary_issuer.at_xpath('//city').remove
		primary_issuer.at_xpath('//stateOrCountryDescription').remove
		primary_issuer.at_xpath('//issuerPhoneNumber').remove
		primary_issuer.at_xpath('//jurisdictionOfInc').remove
		primary_issuer.at_xpath('//issuerPreviousNameList').remove
		primary_issuer.at_xpath('//edgarPreviousNameList').remove
		primary_issuer
	end

	def filterOfferingData
		offering_data = @xml.search '//offeringData'
		offering_data.at_xpath('//businessCombinationTransaction').remove
		offering_data.at_xpath('//salesCommissionsFindersFees').remove
		offering_data.at_xpath('//useOfProceeds').remove
		
		# Storing Required Data from <typesOfSecuritiesOffered>
		is_other_type = offering_data.at_xpath('//typesOfSecuritiesOffered/isOtherType')
		desc_other_type = offering_data.at_xpath('//typesOfSecuritiesOffered/descriptionOfOtherType')
		is_pooled_invest_type = offering_data.at_xpath('//typesOfSecuritiesOffered/descriptionOfOtherType')

		# Removeing Excess Data from <typesOfSecuritiesOffered>
		offering_data.at_xpath('//typesOfSecuritiesOffered').children.remove

		# Adding required data back to <typesOfSecuritiesOffered>
		offering_data.at_xpath('//typesOfSecuritiesOffered').add_child is_other_type unless is_other_type.nil?
		offering_data.at_xpath('//typesOfSecuritiesOffered').add_child desc_other_type unless desc_other_type.nil?
		offering_data.at_xpath('//typesOfSecuritiesOffered').add_child is_pooled_invest_type unless is_pooled_invest_type.nil?

		# Filtering Data from <offeringSalesAmounts>
		offering_data.at_xpath('//offeringSalesAmounts/clarificationOfResponse').remove

		# Filtering Data from <signatureBlock>
		sign_date = offering_data.at_xpath('//signatureBlock/signature/signatureDate')
		offering_data.at_xpath('//signatureBlock').children.remove
		offering_data.at_xpath('//signatureBlock').add_child sign_date
		offering_data
	end
end