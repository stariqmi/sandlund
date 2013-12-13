require 'mechanize'

class EdgarSubmission

	attr_reader :name
	
	def initialize xml
		@xml = xml
		@name = xml.search("//primaryIssuer/entityName")[0].content
	end

	def getSubmissionType
		@xml.search "//submissionType"
	end

	def filterPrimaryIssuer
		primary_issuer = @xml.search '//primaryIssuer'
		
		current = File.open("currently_parsing.xml", "w")
		current.puts primary_issuer
		current.close()

		# Safe removal
		schema_version = primary_issuer.at_xpath('//schemaVersion')
		schema_version.remove unless schema_version.nil?

		test_or_live = primary_issuer.at_xpath('//testOrLive')
		test_or_live.remove unless test_or_live.nil?

		street_1 = primary_issuer.at_xpath('//street1')
		street_2 = primary_issuer.at_xpath('//street2')
		street_1.remove unless street_1.nil?
		street_2.remove unless street_2.nil?

		cik = primary_issuer.at_xpath('//cik')
		cik.remove unless cik.nil?

		city = primary_issuer.at_xpath('//city')
		city.remove unless city.nil?

		scd = primary_issuer.at_xpath('//stateOrCountryDescription')
		scd.remove unless scd.nil?

		issuer_num = primary_issuer.at_xpath('//issuerPhoneNumber')
		issuer_num.remove unless issuer_num.nil?

		jurisdiction = primary_issuer.at_xpath('//jurisdictionOfInc')
		jurisdiction.remove unless jurisdiction.nil?

		ipnl = primary_issuer.at_xpath('//issuerPreviousNameList')
		ipnl.remove unless ipnl.nil?
		
		epnl = primary_issuer.at_xpath('//edgarPreviousNameList')
		epnl.remove unless epnl.nil?

		primary_issuer
	end

	def filterOfferingData
		offering_data = @xml.search '//offeringData'

		# Safe removal
		bct = offering_data.at_xpath('//businessCombinationTransaction')
		bct.remove unless bct.nil?

		scff = offering_data.at_xpath('//salesCommissionsFindersFees')
		scff.remove unless scff.nil?

		use_of_proceeds = offering_data.at_xpath('//useOfProceeds')
		use_of_proceeds.remove unless use_of_proceeds.nil?

		# Storing Required Data from <typesOfSecuritiesOffered>
		is_other_type = offering_data.at_xpath('//typesOfSecuritiesOffered/isOtherType')
		desc_other_type = offering_data.at_xpath('//typesOfSecuritiesOffered/descriptionOfOtherType')
		is_pooled_invest_type = offering_data.at_xpath('//typesOfSecuritiesOffered/descriptionOfOtherType')

		# Removeing Excess Data from <typesOfSecuritiesOffered>
		tso = offering_data.at_xpath('//typesOfSecuritiesOffered')
		if not tso.nil?
			tso.children.remove
		end

		# Adding required data back to <typesOfSecuritiesOffered>
		offering_data.at_xpath('//typesOfSecuritiesOffered').add_child is_other_type unless is_other_type.nil?
		offering_data.at_xpath('//typesOfSecuritiesOffered').add_child desc_other_type unless desc_other_type.nil?
		offering_data.at_xpath('//typesOfSecuritiesOffered').add_child is_pooled_invest_type unless is_pooled_invest_type.nil?

		# Filtering Data from <offeringSalesAmounts>
		cos = offering_data.at_xpath('//offeringSalesAmounts/clarificationOfResponse')
		cos.remove unless cos.nil?

		# Filtering Data from <signatureBlock>
		sign_date = offering_data.at_xpath('//signatureBlock/signature/signatureDate')
		sign_block = offering_data.at_xpath('//signatureBlock')
		if not sign_block.nil?
			sign_block.children.remove
			offering_data.at_xpath('//signatureBlock').add_child sign_date
		end
		offering_data
	end
end