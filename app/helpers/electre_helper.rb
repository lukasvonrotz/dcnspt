# Helper Methods for running the ELECTRE algorithm and the sensitivity analysis
module ElectreHelper
  # return hash with all project alternatives (employee-id if 'idOrCode' is true, employee-code otherwise)
  def getProjectAlternatives(alternativesHash, project, idOrCode)
    project.employees.each_with_index do |employee, index|
      hashkey = 'a' + (index+1).to_s
      alternativesHash[hashkey] = Hash.new()
      alternativesHash[hashkey]['user'] = idOrCode ? employee.id : employee.code
      alternativesHash[hashkey]['rank'] = 0
    end
    return alternativesHash
  end

  # return hash with all project criteria and corresponding thresholds
  def getProjectCriteria(criteriaHash,project)
    Project.find(project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'crit' + (index+1).to_s
      criteriaHash[hashkey] = Hash.new()
      criteriaHash[hashkey]['id'] = 'c' + (index + 1).to_s
      criteriaHash[hashkey]['name'] = criterionparam.criterion.name
      criteriaHash[hashkey]['direction'] = (criterionparam.direction ? 'max' : 'min')
      criteriaHash[hashkey]['indslo'] = criterionparam.inthresslo ? criterionparam.inthresslo.to_f : nil
      criteriaHash[hashkey]['indint'] = criterionparam.inthresint ? criterionparam.inthresint.to_f : nil
      criteriaHash[hashkey]['preslo'] = criterionparam.prefthresslo ? criterionparam.prefthresslo.to_f : nil
      criteriaHash[hashkey]['preint'] = criterionparam.prefthresint ? criterionparam.prefthresint.to_f : nil
      criteriaHash[hashkey]['vetslo'] = criterionparam.vetothresslo ? criterionparam.vetothresslo.to_f : nil
      criteriaHash[hashkey]['vetint'] = criterionparam.vetothresint ? criterionparam.vetothresint.to_f : nil
    end
    return criteriaHash
  end

  # return hash with all project criteria and corresponding thresholds (for the sensitivity analysis)
  def getProjectCriteriaSensitivity(criteriaHash,project,params,iteration)
    Project.find(project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'crit' + (index+1).to_s
      criteriaHash[hashkey] = Hash.new()
      criteriaHash[hashkey]['id'] = 'c' + (index + 1).to_s
      criteriaHash[hashkey]['name'] = criterionparam.criterion.name
      criteriaHash[hashkey]['direction'] = (criterionparam.direction ? 'max' : 'min')



      criteriaHash[hashkey]['indslo'] = params['inthresslo' + criterionparam.criterion.id.to_s][iteration] != 'NaN' ?
          params['inthresslo' + criterionparam.criterion.id.to_s][iteration].to_f : nil
      criteriaHash[hashkey]['indint'] = params['inthresint' + criterionparam.criterion.id.to_s][iteration] != 'NaN' ?
          params['inthresint' + criterionparam.criterion.id.to_s][iteration].to_f : nil
      criteriaHash[hashkey]['preslo'] = params['prefthresslo' + criterionparam.criterion.id.to_s][iteration] != 'NaN' ?
          params['prefthresslo' + criterionparam.criterion.id.to_s][iteration].to_f : nil
      criteriaHash[hashkey]['preint'] = params['prefthresint' + criterionparam.criterion.id.to_s][iteration] != 'NaN' ?
          params['prefthresint' + criterionparam.criterion.id.to_s][iteration].to_f : nil

      criteriaHash[hashkey]['vetslo'] = params['vetothresslo' + criterionparam.criterion.id.to_s][iteration] != 'NaN' ?
          params['vetothresslo' + criterionparam.criterion.id.to_s][iteration].to_f : nil
      criteriaHash[hashkey]['vetint'] = params['vetothresint' + criterionparam.criterion.id.to_s][iteration] != 'NaN' ?
          params['vetothresint' + criterionparam.criterion.id.to_s][iteration].to_f : nil
    end
    return criteriaHash
  end

  # return hash with weights of all project criteria
  def getProjectWeights(weightsHash,project)
    Project.find(project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'c' + (index+1).to_s
      weightsHash[hashkey] = Hash.new()
      weightsHash[hashkey]['id'] = 'c' + (index + 1).to_s
      weightsHash[hashkey]['weight'] = criterionparam.weight
    end
    return weightsHash
  end

  # return hash with weights of all project criteria (for sensitivity analysis)
  def getProjectWeightsSensitivity(weightsHash,project,params,iteration)
    Project.find(project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'c' + (index+1).to_s
      weightsHash[hashkey] = Hash.new()
      weightsHash[hashkey]['id'] = 'c' + (index + 1).to_s
      weightsHash[hashkey]['weight'] = params['weight' + criterionparam.criterion.id.to_s][iteration].to_f
    end
    return weightsHash
  end

  # return adjusted alternatives hash with the ranks based on the answer from the distillation web service
  def rankAlternatives(alternativesHash, rankHash)
    rankHash['Envelope']['Body']['requestSolutionResponse']['rank']['XMCDA']['alternativesValues'].each do |key, pair|
      pair.each do |alternative|
        key = alternative['alternativeID']
        rank = alternative['value']['integer']
        # set all alternative ranks in alternatives-hash
        alternativesHash[key]['rank'] = rank
      end
    end
    return alternativesHash
  end

  # call 'ElectreConcordance' web service from decision deck and return an xml with the web service answer
  # see http://www.decision-deck.org/ws/wsd-ElectreConcordance-PUT.html for further information
  def buildSoapRequestConcordance(concordanceInput)
    concordanceOutput1 = Nokogiri::XML(postXmlToWebservice(concordanceInput, "http://webservices.decision-deck.org/soap/ElectreConcordance-PUT.py"))
    concordanceOutput2 = Soapcreator.getSoapTicket(concordanceOutput1.xpath("//ticket/text()").to_s)
    concordanceOutput = Nokogiri::XML(postXmlToWebservice(concordanceOutput2, "http://webservices.decision-deck.org/soap/ElectreConcordance-PUT.py"))
    xml = concordanceOutput.to_s.gsub! '&lt;', '<'
    xml = xml.to_s.gsub! '&gt;', '>'
    return xml
  end

  # call 'ElectreDiscordance' web service from decision deck and return an xml with the web service answer
  # see http://www.decision-deck.org/ws/wsd-ElectreDiscordance-PUT.html for further information
  def buildSoapRequestDiscordance(discordanceInput)
    discordanceOutput1 = Nokogiri::XML(postXmlToWebservice(discordanceInput, "http://webservices.decision-deck.org/soap/ElectreDiscordance-PUT.py"))
    discordanceOutput2 = Soapcreator.getSoapTicket(discordanceOutput1.xpath("//ticket/text()").to_s)
    discordanceOutput = Nokogiri::XML(postXmlToWebservice(discordanceOutput2, "http://webservices.decision-deck.org/soap/ElectreDiscordance-PUT.py"))
    xml = discordanceOutput.to_s.gsub! '&lt;', '<'
    xml = xml.to_s.gsub! '&gt;', '>'
    return xml
  end

  # call 'ElectreCredibility' web service from decision deck and return an xml with the web service answer
  # see http://www.decision-deck.org/ws/wsd-ElectreCredibility-PUT.html for further information
  def buildSoapRequestCredibility(credibilityInput)
    credibilityOutput1 = Nokogiri::XML(postXmlToWebservice(credibilityInput,"http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"))
    credibilityOutput2 = Soapcreator.getSoapTicket(credibilityOutput1.xpath("//ticket/text()").to_s)
    credibilityOutput = Nokogiri::XML(postXmlToWebservice(credibilityOutput2,"http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"))
    xml = credibilityOutput.to_s.gsub! '&lt;', '<'
    xml = xml.to_s.gsub! '&gt;', '>'
    return xml
  end

  # call 'ElectreDistillation' web service from decision deck and return an xml with the web service answer
  # see http://www.decision-deck.org/ws/wsd-ElectreDistillation-PUT.html for further information
  def buildSoapRequestDistillation(distillationInput)
    distillationOutput1 = Nokogiri::XML(postXmlToWebservice(distillationInput,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    distillationOutput2 = Soapcreator.getSoapTicket(distillationOutput1.xpath("//ticket/text()").to_s)
    distillationOutput = Nokogiri::XML(postXmlToWebservice(distillationOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    xml = distillationOutput.to_s.gsub! '&lt;', '<'
    xml = xml.to_s.gsub! '&gt;', '>'
    return xml
  end

  # call 'ElectreDistillationRank' web service from decision deck and return an xml with the web service answer
  # see http://www.decision-deck.org/ws/wsd-ElectreDistillationRank-PUT.html for further information
  def buildSoapRequestRanking(rankingInput)
    rankingOutput1 = Nokogiri::XML(postXmlToWebservice(rankingInput,"http://webservices.decision-deck.org/soap/ElectreDistillationRank-PUT.py"))
    rankingOutput2 = Soapcreator.getSoapTicket(rankingOutput1.xpath("//ticket/text()").to_s)
    rankingOutput = Nokogiri::XML(postXmlToWebservice(rankingOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillationRank-PUT.py"))
    xml = rankingOutput.to_s.gsub! '&lt;', '<'
    xml = xml.to_s.gsub! '&gt;', '>'
    return xml
  end

  # prepare XML for further processing
  # extract only the part of the XML which is in between the two makerstrings
  def convertXML(xml,markerstring1,markerstring2)
    puts xml
    newXML = xml[/#{markerstring1}(.*?)#{markerstring2}/m, 1]
    return newXML
  end

  # perform web service call (with SOAP)
  def postXmlToWebservice(xml,url)
    host = url
    uri = URI.parse host
    request = Net::HTTP::Post.new uri.path
    request.body = xml
    request.content_type = 'application/soap+xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    return response.body
  end
end