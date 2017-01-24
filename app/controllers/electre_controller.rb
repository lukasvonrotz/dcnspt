class ElectreController < ApplicationController

  require 'net/http'
  require 'nokogiri'

  def index

    @project = Project.find(params[:project_id])

    @alternatives = Hash.new()
    Employee.all.each_with_index do |employee, index|
      if index<10
        hashkey = 'a' + (index+1).to_s
        @alternatives[hashkey] = Hash.new()
        @alternatives[hashkey]['user'] = employee.id
        @alternatives[hashkey]['rank'] = 0
      end
    end


    ####buildSoapRequestConcordance#####
    soapInstance = Soapcreator.new
    concordanceInput = soapInstance.getSoapConcordance
    concordanceOutput1 = Nokogiri::XML(postXmlToWebservice(concordanceInput, "http://webservices.decision-deck.org/soap/ElectreConcordance-PUT.py"))
    concordanceOutput2 = Soapcreator.getSoapTicket(concordanceOutput1.xpath("//ticket/text()").to_s)
    concordanceOutput = Nokogiri::XML(postXmlToWebservice(concordanceOutput2, "http://webservices.decision-deck.org/soap/ElectreConcordance-PUT.py"))
    xml = concordanceOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    hashConcordance = Hash.from_xml(xml.gsub("\n", ""))

    #hashConcordance['Envelope']['Body']['requestSolutionResponse']['concordance']['XMCDA']['alternativesComparisons']['pairs'].each do |key, pair|
    #  pair.each do |relation|
    #    puts relation['initial']['alternativeID']
    #    puts relation['terminal']['alternativeID']
    #    puts relation['value']['real']
    #  end
    #end
    input_string = xml
    str1_markerstring = "<alternativesComparisons>"
    str2_markerstring = "</alternativesComparisons>"
    concordanceXML = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]




    ####buildSoapRequestDiscordance#####
    discordanceInput = soapInstance.getSoapDiscordance
    discordanceOutput1 = Nokogiri::XML(postXmlToWebservice(discordanceInput, "http://webservices.decision-deck.org/soap/ElectreDiscordance-PUT.py"))
    discordanceOutput2 = Soapcreator.getSoapTicket(discordanceOutput1.xpath("//ticket/text()").to_s)
    discordanceOutput = Nokogiri::XML(postXmlToWebservice(discordanceOutput2, "http://webservices.decision-deck.org/soap/ElectreDiscordance-PUT.py"))
    xml = discordanceOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    hashDiscordance = Hash.from_xml(xml.gsub("\n", ""))
    #hashDiscordance['Envelope']['Body']['requestSolutionResponse']['discordance']['XMCDA']['alternativesComparisons']['pairs'].each do |key, pair|
    #  pair.each do |relation|
    #    puts relation['initial']['alternativeID']
    #    puts relation['terminal']['alternativeID']
    #    relation['values'].each do |key,value|
    #      value.each do |key,disvalue|
    #        puts key['real']
    #      end
    #    end
    #  end
    #end
    input_string = xml
    str1_markerstring = "<alternativesComparisons>"
    str2_markerstring = "</alternativesComparisons>"
    discordanceXML = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]



    ####buildSoapRequestCredibility#####
    credibilityInput = soapInstance.getSoapCredibility(concordanceXML, discordanceXML)
    credibilityOutput1 = Nokogiri::XML(postXmlToWebservice(credibilityInput,"http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"))
    credibilityOutput2 = Soapcreator.getSoapTicket(credibilityOutput1.xpath("//ticket/text()").to_s)
    credibilityOutput = Nokogiri::XML(postXmlToWebservice(credibilityOutput2,"http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"))
    xml = credibilityOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    input_string = xml
    str1_markerstring = "<alternativesComparisons>"
    str2_markerstring = "</alternativesComparisons>"
    credibilityXML = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]



    ####buildSoapRequestDistillations#####
    ######downwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'downwards', params[:alpha], params[:beta])
    distillationOutput1 = Nokogiri::XML(postXmlToWebservice(distillationInput,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    distillationOutput2 = Soapcreator.getSoapTicket(distillationOutput1.xpath("//ticket/text()").to_s)
    distillationOutput = Nokogiri::XML(postXmlToWebservice(distillationOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    xml = distillationOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    input_string = xml
    str1_markerstring = "<alternativesValues>"
    str2_markerstring = "</alternativesValues>"
    downwardsXML = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]

    ######upwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'upwards', params[:alpha], params[:beta])
    distillationOutput1 = Nokogiri::XML(postXmlToWebservice(distillationInput,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    distillationOutput2 = Soapcreator.getSoapTicket(distillationOutput1.xpath("//ticket/text()").to_s)
    distillationOutput = Nokogiri::XML(postXmlToWebservice(distillationOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    xml = distillationOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    input_string = xml
    str1_markerstring = "<alternativesValues>"
    str2_markerstring = "</alternativesValues>"
    upwardsXML = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]


    ####buildSoapRequestRanking#####
    rankingInput = soapInstance.getSoapRanking(downwardsXML, upwardsXML)
    rankingOutput1 = Nokogiri::XML(postXmlToWebservice(rankingInput,"http://webservices.decision-deck.org/soap/ElectreDistillationRank-PUT.py"))
    rankingOutput2 = Soapcreator.getSoapTicket(rankingOutput1.xpath("//ticket/text()").to_s)
    rankingOutput = Nokogiri::XML(postXmlToWebservice(rankingOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillationRank-PUT.py"))
    xml = rankingOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    hashRanking = Hash.from_xml(xml.gsub("\n", ""))
    hashRanking['Envelope']['Body']['requestSolutionResponse']['rank']['XMCDA']['alternativesValues'].each do |key, pair|
      pair.each do |alternative|
        key = alternative['alternativeID']
        rank = alternative['value']['integer']
        @alternatives[key]['rank'] = rank
      end
    end

    puts @alternatives

  end



  private

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
