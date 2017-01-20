class ElectreController < ApplicationController

  require 'net/http'
  require 'nokogiri'

  def index

    @project = Project.find(params[:project_id])


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
    credibilityInput = soapInstance.getSoapDistillation(credibilityXML,'downwards')
    credibilityOutput1 = Nokogiri::XML(postXmlToWebservice(credibilityInput,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    credibilityOutput2 = Soapcreator.getSoapTicket(credibilityOutput1.xpath("//ticket/text()").to_s)
    credibilityOutput = Nokogiri::XML(postXmlToWebservice(credibilityOutput2,"http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py"))
    xml = credibilityOutput.to_s.gsub! '&lt;', '<'
    xml = xml.gsub! '&gt;', '>'
    puts xml


    ######upwards#######################









    puts 'concordanceXML'
    puts concordanceXML
    puts 'discordanceXML'
    puts discordanceXML
    puts 'credibilityXML'
    puts credibilityXML

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
