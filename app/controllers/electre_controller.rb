class ElectreController < ApplicationController

  require 'net/http'
  require 'nokogiri'

  skip_before_filter :verify_authenticity_token

  def index

    @project = Project.find(params[:project_id])
    @alpha = params[:alpha]
    @beta = params[:beta]

    @alternatives = Hash.new()
    @project.employees.each_with_index do |employee, index|
      hashkey = 'a' + (index+1).to_s
      @alternatives[hashkey] = Hash.new()
      @alternatives[hashkey]['user'] = employee.id
      @alternatives[hashkey]['rank'] = 0
    end

    soapInstance = Soapcreator.new
    soapInstance.project = @project.id


    criteria = Hash.new()
    Project.find(@project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'crit' + (index+1).to_s
      criteria[hashkey] = Hash.new()
      criteria[hashkey]['id'] = 'c' + (index + 1).to_s
      criteria[hashkey]['name'] = criterionparam.criterion.name
      criteria[hashkey]['direction'] = (criterionparam.direction ? 'max' : 'min')
      criteria[hashkey]['indslo'] = criterionparam.inthresslo ? criterionparam.inthresslo.to_f : nil
      criteria[hashkey]['indint'] = criterionparam.inthresint ? criterionparam.inthresint.to_f : nil
      criteria[hashkey]['preslo'] = criterionparam.prefthresslo ? criterionparam.prefthresslo.to_f : nil
      criteria[hashkey]['preint'] = criterionparam.prefthresint ? criterionparam.prefthresint.to_f : nil
      criteria[hashkey]['vetslo'] = criterionparam.vetothresslo ? criterionparam.vetothresslo.to_f : nil
      criteria[hashkey]['vetint'] = criterionparam.vetothresint ? criterionparam.vetothresint.to_f : nil
    end

    weights = Hash.new()
    Project.find(@project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'c' + (index+1).to_s
      weights[hashkey] = Hash.new()
      weights[hashkey]['id'] = 'c' + (index + 1).to_s
      weights[hashkey]['weight'] = criterionparam.weight
    end

    ####buildSoapRequestConcordance#####
    concordanceInput = soapInstance.getSoapConcordance(criteria,weights)
    xml = buildSoapRequestConcordance(concordanceInput)
    xmlConcordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ####buildSoapRequestDiscordance#####
    discordanceInput = soapInstance.getSoapDiscordance(criteria,weights)
    xml = buildSoapRequestDiscordance(discordanceInput)
    xmlDiscordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ####buildSoapRequestDistillations#####
    credibilityInput = soapInstance.getSoapCredibility(xmlConcordance, xmlDiscordance)
    xml = buildSoapRequestCredibility(credibilityInput)
    credibilityXML = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')


    ####buildSoapRequestDistillations#####

    ######downwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'downwards', @alpha, @beta)
    xml = buildSoapRequestDistillation(distillationInput)
    downwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')

    ######upwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'upwards', @alpha, @beta)
    xml = buildSoapRequestDistillation(distillationInput)
    upwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')


    ####buildSoapRequestRanking#####
    rankingInput = soapInstance.getSoapRanking(downwardsXML, upwardsXML)
    xml = buildSoapRequestRanking(rankingInput)
    hashRanking = Hash.from_xml(xml.gsub("\n", ""))
    hashRanking['Envelope']['Body']['requestSolutionResponse']['rank']['XMCDA']['alternativesValues'].each do |key, pair|
      pair.each do |alternative|
        key = alternative['alternativeID']
        rank = alternative['value']['integer']
        @alternatives[key]['rank'] = rank
      end
    end

    @alternatives = @alternatives.sort_by{|x,y| y['rank'].to_i}.to_h

  end

  def sensitivity

    @project = Project.find(params[:project_id])
    @alpha = params[:alpha]
    @beta = params[:beta]
    @iteration = params['iteration'].to_i

    soapInstance = Soapcreator.new
    soapInstance.project = @project.id

    ###build alternatives hash###
    @alternatives = Hash.new()
    @project.employees.each_with_index do |employee, index|
      hashkey = 'a' + (index+1).to_s
      @alternatives[hashkey] = Hash.new()
      @alternatives[hashkey]['user'] = employee.code
      @alternatives[hashkey]['rank'] = 0
    end

    ###build criteria hash###
    criteria = Hash.new()
    Project.find(@project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'crit' + (index+1).to_s
      criteria[hashkey] = Hash.new()
      criteria[hashkey]['id'] = 'c' + (index + 1).to_s
      criteria[hashkey]['name'] = criterionparam.criterion.name
      criteria[hashkey]['direction'] = (criterionparam.direction ? 'max' : 'min')

      criteria[hashkey]['indslo'] = params['inthresslo' + criterionparam.criterion.id.to_s][@iteration].to_f ?
          params['inthresslo' + criterionparam.criterion.id.to_s][@iteration].to_f : nil
      criteria[hashkey]['indint'] = params['inthresint' + criterionparam.criterion.id.to_s][@iteration].to_f ?
          params['inthresint' + criterionparam.criterion.id.to_s][@iteration].to_f : nil
      criteria[hashkey]['preslo'] = params['prefthresslo' + criterionparam.criterion.id.to_s][@iteration].to_f ?
          params['prefthresslo' + criterionparam.criterion.id.to_s][@iteration].to_f : nil
      criteria[hashkey]['preint'] = params['prefthresint' + criterionparam.criterion.id.to_s][@iteration].to_f ?
          params['prefthresint' + criterionparam.criterion.id.to_s][@iteration].to_f : nil
      criteria[hashkey]['vetslo'] = params['vetothresslo' + criterionparam.criterion.id.to_s][@iteration].to_f ?
          params['vetothresslo' + criterionparam.criterion.id.to_s][@iteration].to_f : nil
      criteria[hashkey]['vetint'] = params['vetothresint' + criterionparam.criterion.id.to_s][@iteration].to_f ?
          params['vetothresint' + criterionparam.criterion.id.to_s][@iteration].to_f : nil
    end

    ###build weight hash###
    weights = Hash.new()
    Project.find(@project).criterionparams.each_with_index do |criterionparam, index|
      hashkey = 'c' + (index+1).to_s
      weights[hashkey] = Hash.new()
      weights[hashkey]['id'] = 'c' + (index + 1).to_s
      weights[hashkey]['weight'] = params['weight' + criterionparam.criterion.id.to_s][@iteration].to_f
    end

    ###buildSoapRequestConcordance#####
    concordanceInput = soapInstance.getSoapConcordance(criteria,weights)
    xml = buildSoapRequestConcordance(concordanceInput)
    xmlConcordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ###buildSoapRequestDiscordance#####
    discordanceInput = soapInstance.getSoapDiscordance(criteria,weights)
    xml = buildSoapRequestDiscordance(discordanceInput)
    xmlDiscordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ####buildSoapRequestDistillations#####
    credibilityInput = soapInstance.getSoapCredibility(xmlConcordance, xmlDiscordance)
    xml = buildSoapRequestCredibility(credibilityInput)
    credibilityXML = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')


    ####buildSoapRequestDistillations#####

    ######downwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'downwards', @alpha, @beta)
    xml = buildSoapRequestDistillation(distillationInput)
    downwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')

    ######upwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'upwards', @alpha, @beta)
    xml = buildSoapRequestDistillation(distillationInput)
    upwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')


    ####buildSoapRequestRanking#####
    rankingInput = soapInstance.getSoapRanking(downwardsXML, upwardsXML)
    xml = buildSoapRequestRanking(rankingInput)
    hashRanking = Hash.from_xml(xml.gsub("\n", ""))
    hashRanking['Envelope']['Body']['requestSolutionResponse']['rank']['XMCDA']['alternativesValues'].each do |key, pair|
      pair.each do |alternative|
        key = alternative['alternativeID']
        rank = alternative['value']['integer']
        @alternatives[key]['rank'] = rank
      end
    end

    @alternatives = @alternatives.sort_by{|x,y| y['rank']}.to_h
    @alternatives['iteration'] = params['iteration']

    respond_to do |format|
      format.html {
        render :json => @alternatives
      }
    end
  end




  private

  def buildSoapRequestConcordance(concordanceInput)
    concordanceOutput1 = Nokogiri::XML(postXmlToWebservice(concordanceInput, "http://webservices.decision-deck.org/soap/ElectreConcordance-PUT.py"))
    concordanceOutput2 = Soapcreator.getSoapTicket(concordanceOutput1.xpath("//ticket/text()").to_s)
    concordanceOutput = Nokogiri::XML(postXmlToWebservice(concordanceOutput2, "http://webservices.decision-deck.org/soap/ElectreConcordance-PUT.py"))
    xml = concordanceOutput.to_s.gsub! '&lt;', '<'
    return xml.gsub! '&gt;', '>'
  end

  def buildSoapRequestDiscordance(discordanceInput)
    discordanceOutput1 = Nokogiri::XML(postXmlToWebservice(discordanceInput, "http://webservices.decision-deck.org/soap/ElectreDiscordance-PUT.py"))
    discordanceOutput2 = Soapcreator.getSoapTicket(discordanceOutput1.xpath("//ticket/text()").to_s)
    discordanceOutput = Nokogiri::XML(postXmlToWebservice(discordanceOutput2, "http://webservices.decision-deck.org/soap/ElectreDiscordance-PUT.py"))
    xml = discordanceOutput.to_s.gsub! '&lt;', '<'
    return xml.gsub! '&gt;', '>'
  end

  def buildSoapRequestCredibility(credibilityInput)
    credibilityOutput1 = Nokogiri::XML(postXmlToWebservice(credibilityInput,"http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"))
    credibilityOutput2 = Soapcreator.getSoapTicket(credibilityOutput1.xpath("//ticket/text()").to_s)
    credibilityOutput = Nokogiri::XML(postXmlToWebservice(credibilityOutput2,"http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"))
    xml = credibilityOutput.to_s.gsub! '&lt;', '<'
    return xml.gsub! '&gt;', '>'
  end

  def buildSoapRequestDistillation(distillationInput)
    distillationOutput1 = Nokogiri::XML(postXmlToWebservice(distillationInput,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    distillationOutput2 = Soapcreator.getSoapTicket(distillationOutput1.xpath("//ticket/text()").to_s)
    distillationOutput = Nokogiri::XML(postXmlToWebservice(distillationOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    xml = distillationOutput.to_s.gsub! '&lt;', '<'
    return xml.gsub! '&gt;', '>'
  end

  def buildSoapRequestRanking(rankingInput)
    rankingOutput1 = Nokogiri::XML(postXmlToWebservice(rankingInput,"http://webservices.decision-deck.org/soap/ElectreDistillationRank-PUT.py"))
    rankingOutput2 = Soapcreator.getSoapTicket(rankingOutput1.xpath("//ticket/text()").to_s)
    rankingOutput = Nokogiri::XML(postXmlToWebservice(rankingOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillationRank-PUT.py"))
    xml = rankingOutput.to_s.gsub! '&lt;', '<'
    return xml.gsub! '&gt;', '>'
  end

  def convertXML(xml,markerstring1,markerstring2)
    return xml[/#{markerstring1}(.*?)#{markerstring2}/m, 1]
  end

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
