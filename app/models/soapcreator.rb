class Soapcreator

  attr_accessor :alternatives, :criteria, :performance, :method_parameters, :weights, :concordance, :discordance, :credibility

  @@soapheader =
      '<?xml version="1.0" encoding="UTF-8"?>
        <SOAP-ENV:Envelope
        SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"
        xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/1999/XMLSchema">
      <SOAP-ENV:Body>
      <submitProblem SOAP-ENC:root="1">'

  @@soapfooter =
      '</submitProblem>
       </SOAP-ENV:Body>
       </SOAP-ENV:Envelope>'

  @@soapheader_ticket =
      '<?xml version="1.0" encoding="UTF-8"?>
      <SOAP-ENV:Envelope
        SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"
        xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/1999/XMLSchema">
        <SOAP-ENV:Body>
      <requestSolution SOAP-ENC:root="1">'
  @@soapfooter_ticket =
      '</requestSolution>
      </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>'


  @@alternativesheader = '<alternatives xsi:type="xsd:string">'
  @@alternativesfooter = '</alternatives>'
  @@criteriaheader = '<criteria xsi:type="xsd:string">'
  @@criteriafooter = '</criteria>'
  @@concordanceheader = '<concordance xsi:type="xsd:string">'
  @@concordancefooter = '</concordance>'
  @@discordanceheader = '<discordance xsi:type="xsd:string">'
  @@discordancefooter = '</discordance>'
  @@credibilityheader = '<credibility xsi:type="xsd:string">'
  @@credibilityfooter = '</credibility>'
  @@performanceheader = '<performance_table xsi:type="xsd:string">'
  @@performancefooter = '</performance_table>'
  @@method_parametersheader = '<method_parameters xsi:type="xsd:string">'
  @@method_parametersfooter = '</method_parameters>'
  @@weightsheader = '<weights xsi:type="xsd:string">'
  @@weightsfooter = '</weights>'







  def getSoapConcordance

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(0)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######criteria######
    xml = buildCriteriaXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @criteria = xml_raw

    ########performance#########
    xml = buildPerformanceXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @performance = xml_raw

    ######method_parameter######
    xml  = buildMethodparamsXML(0,'')
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw


    ##########weights###########
    xml = buildWeightsXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @weights = xml_raw



    return @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@criteriaheader.to_s + @criteria.to_s + @@criteriafooter.to_s +
        @@performanceheader.to_s + @performance.to_s + @@performancefooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
        @@weightsheader.to_s + @weights.to_s + @@weightsfooter.to_s +
        @@soapfooter.to_s
  end

  def getSoapDiscordance

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(0)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######criteria######
    xml = buildCriteriaXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @criteria = xml_raw

    ########performance#########
    xml = buildPerformanceXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @performance = xml_raw

    ######method_parameter######
    xml  = buildMethodparamsXML(1,'')
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw


    ##########weights###########
    xml = buildWeightsXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @weights = xml_raw



    return @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@criteriaheader.to_s + @criteria.to_s + @@criteriafooter.to_s +
        @@performanceheader.to_s + @performance.to_s + @@performancefooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
        @@weightsheader.to_s + @weights.to_s + @@weightsfooter.to_s +
        @@soapfooter.to_s
  end

  def getSoapCredibility(concordanceXML, discordanceXML)

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(0)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######concordance######
    xml = buildConcordanceXML(concordanceXML)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @concordance = xml_raw

    ########discordance#########
    xml = buildDiscordanceXML(discordanceXML)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @discordance = xml_raw

    ######method_parameter######
    xml  = buildMethodparamsXML(2,'')
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw

    return @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@concordanceheader.to_s + @concordance.to_s + @@concordancefooter.to_s +
        @@discordanceheader.to_s + @discordance.to_s + @@discordancefooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
        @@soapfooter.to_s
  end

  def getSoapDistillation(credibilityXML, direction)

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(1)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######credibility######
    xml = buildCredibilityXML(credibilityXML)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @credibility = xml_raw

    ######method_parameter######
    xml  = buildMethodparamsXML(3,direction)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw


    return @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@credibilityheader.to_s + @credibility.to_s + @@credibilityfooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
        @@soapfooter.to_s
  end







  def self.getSoapTicket(ticket)
    @@soapheader_ticket.to_s +
        '<ticket xsi:type="xsd:string">' + ticket + '</ticket>' +
        @@soapfooter_ticket.to_s
  end

  def buildAlternativesXML(mode)
    alternatives = Hash.new()
    Employee.all.each_with_index do |employee, index|
      if index<10
        hashkey = 'alt' + (index+1).to_s
        alternatives[hashkey] = Hash.new()
        alternatives[hashkey]['id'] = 'a' + (index + 1).to_s
        alternatives[hashkey]['name'] = employee.firstname + ' ' + employee.surname
      end
    end
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      case mode
        when 0
          xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.0.0", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") {
            xml.projectReference {
              xml.parent.namespace = nil
              xml.comment_ 'All users that are considered for the electre iv algorithm'
            }
            xml.alternatives {
              xml.parent.namespace = nil
              alternatives.each do |alt|
                xml.alternative(:id => "#{alt[1]['id']}", :name => "#{alt[1]['name']}")
              end
            }
          }
        when 1
          xml['xmcda'].XMCDA("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.0.0",
                             "xsi:schemaLocation" => "http://www.decision-deck.org/2009/XMCDA-2.0.0 http://sma.uni.lu/d2cms/xmcda/_downloads/XMCDA-2.0.0.xsd") {
            xml.projectReference {
              xml.parent.namespace = nil
              xml.comment_ 'All users that are considered for the electre iv algorithm'
            }
            xml.alternatives {
              xml.parent.namespace = nil
              alternatives.each do |alt|
                xml.alternative(:id => "#{alt[1]['id']}", :name => "#{alt[1]['name']}")
              end
            }
          }
        end
    end
    return builder.to_xml
  end

  def buildCriteriaXML
    criteria = Hash.new()
    hashkey = 'crit1'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c1'
    criteria[hashkey]['name'] = 'Price'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indslo'] = '0.08'
    criteria[hashkey]['indint'] = '-2000.0'
    criteria[hashkey]['preslo'] = '0.115'
    criteria[hashkey]['preint'] = '-2654.87'
    criteria[hashkey]['vetslo'] = '0.474'
    criteria[hashkey]['vetint'] = '26315.79'
    hashkey = 'crit2'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c2'
    criteria[hashkey]['name'] = 'Vmax'
    criteria[hashkey]['direction'] = 'max'
    criteria[hashkey]['indslo'] = '0.02'
    criteria[hashkey]['indint'] = '0'
    criteria[hashkey]['preslo'] = '0.05'
    criteria[hashkey]['preint'] = '0'
    hashkey = 'crit3'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c3'
    criteria[hashkey]['name'] = 'C120'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indslo'] = '0'
    criteria[hashkey]['indint'] = '1'
    criteria[hashkey]['preslo'] = '0'
    criteria[hashkey]['preint'] = '2'
    criteria[hashkey]['vetslo'] = '0'
    criteria[hashkey]['vetint'] = '4'
    hashkey = 'crit4'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c4'
    criteria[hashkey]['name'] = 'Coff'
    criteria[hashkey]['direction'] = 'max'
    criteria[hashkey]['indslo'] = '0'
    criteria[hashkey]['indint'] = '100'
    criteria[hashkey]['preslo'] = '0'
    criteria[hashkey]['preint'] = '200'
    hashkey = 'crit5'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c5'
    criteria[hashkey]['name'] = 'Acc'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indslo'] = '0.1'
    criteria[hashkey]['indint'] = '-0.5'
    criteria[hashkey]['preslo'] = '0.2'
    criteria[hashkey]['preint'] = '-1'
    criteria[hashkey]['vetslo'] = '0.5'
    criteria[hashkey]['vetint'] = '3'
    hashkey = 'crit6'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c6'
    criteria[hashkey]['name'] = 'Frei'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indslo'] = '0'
    criteria[hashkey]['indint'] = '0'
    criteria[hashkey]['preslo'] = '0'
    criteria[hashkey]['preint'] = '5'
    criteria[hashkey]['vetslo'] = '0'
    criteria[hashkey]['vetint'] = '15'
    hashkey = 'crit7'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c7'
    criteria[hashkey]['name'] = 'Brui'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indslo'] = '0'
    criteria[hashkey]['indint'] = '3'
    criteria[hashkey]['preslo'] = '0'
    criteria[hashkey]['preint'] = '5'
    criteria[hashkey]['vetslo'] = '0'
    criteria[hashkey]['vetint'] = '15'

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.criteria{
          xml.parent.namespace = nil
          criteria.each_with_index do |criterion, index|
            xml.criterion(:id => "#{criterion[1]['id']}", :name => "#{criterion[1]['name']}") {
              xml.scale {
                xml.quantitative {
                  xml.preferenceDirection "#{criterion[1]['direction']}"
                }
              }
              xml.thresholds {
                if criterion[1]['indslo']
                  xml.threshold(:mcdaConcept => "indifference") {
                    xml.linear {
                      xml.slope {
                        xml.real "#{criterion[1]['indslo']}"
                      }
                      xml.intercept {
                        xml.real "#{criterion[1]['indint']}"
                      }
                    }
                  }
                end
                if criterion[1]['preslo']
                  xml.threshold(:mcdaConcept => "preference") {
                    xml.linear {
                      xml.slope {
                        xml.real "#{criterion[1]['preslo']}"
                      }
                      xml.intercept {
                        xml.real "#{criterion[1]['preint']}"
                      }
                    }
                  }
                end
                if criterion[1]['vetslo']
                  xml.threshold(:mcdaConcept => "veto") {
                    xml.linear {
                      xml.slope {
                        xml.real "#{criterion[1]['vetslo']}"
                      }
                      xml.intercept {
                        xml.real "#{criterion[1]['vetint']}"
                      }
                    }
                  }
                end
              }
            }
          end
        }
      }
    end
    return builder.to_xml
  end

  def buildPerformanceXML
    performance = Hash.new()
    hashkey = 'a1'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a1'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '103000.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '171.3'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '7.65'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '352.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '11.6'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '88.0'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '69.7'
    hashkey = 'a2'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a2'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '101300.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '205.3'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '7.9'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '203.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '8.4'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '78.3'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '73.4'
    hashkey = 'a3'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a3'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '156400.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '221.7'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '7.9'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '391.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '8.4'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '81.5'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '69.0'
    hashkey = 'a4'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a4'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '267400.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '230.7'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '10.5'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '419.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '8.6'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '64.7'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '65.6'
    hashkey = 'a5'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a5'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '49900.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '122.6'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '8.3'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '120.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '23.7'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '74.1'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '76.4'
    hashkey = 'a6'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a6'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '103600.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '205.1'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '8.2'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '265.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '8.1'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '81.7'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '73.6'
    hashkey = 'a7'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a7'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '103000.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '178.0'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '7.2'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '419.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '11.4'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '77.6'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '66.2'
    hashkey = 'a8'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a8'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '170100.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '226.0'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '9.1'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '419.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '8.1'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '74.7'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '71.7'
    hashkey = 'a9'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a9'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '279700.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '233.8'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '10.9'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '359.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '7.8'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '75.5'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '70.9'
    hashkey = 'a10'
    performance[hashkey] = Hash.new()
    performance[hashkey]['id'] = 'a10'
    performance[hashkey]['crit1'] = 'c1'
    performance[hashkey]['val1'] = '405000.0'
    performance[hashkey]['crit2'] = 'c2'
    performance[hashkey]['val2'] = '265.0'
    performance[hashkey]['crit3'] = 'c3'
    performance[hashkey]['val3'] = '10.3'
    performance[hashkey]['crit4'] = 'c4'
    performance[hashkey]['val4'] = '265.0'
    performance[hashkey]['crit5'] = 'c5'
    performance[hashkey]['val5'] = '6.0'
    performance[hashkey]['crit6'] = 'c6'
    performance[hashkey]['val6'] = '74.7'
    performance[hashkey]['crit7'] = 'c7'
    performance[hashkey]['val7'] = '72.0'


    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.title 'Alternatives performances'
          xml.comment_ 'Performance Table'
        }
        xml.performanceTable(:mcdaConcept => "REAL"){
          xml.parent.namespace = nil
          performance.each_with_index do |perf, index|
            xml.alternativePerformances {
              xml.alternativeID "#{perf[1]['id']}"
              xml.performance {
                xml.criterionID "#{perf[1]['crit1']}"
                xml.value {
                  xml.real "#{perf[1]['val1']}"
                }
              }
              xml.performance {
                xml.criterionID "#{perf[1]['crit2']}"
                xml.value {
                  xml.real "#{perf[1]['val2']}"
                }
              }
              xml.performance {
                xml.criterionID "#{perf[1]['crit3']}"
                xml.value {
                  xml.real "#{perf[1]['val3']}"
                }
              }
              xml.performance {
                xml.criterionID "#{perf[1]['crit4']}"
                xml.value {
                  xml.real "#{perf[1]['val4']}"
                }
              }
              xml.performance {
                xml.criterionID "#{perf[1]['crit5']}"
                xml.value {
                  xml.real "#{perf[1]['val5']}"
                }
              }
              xml.performance {
                xml.criterionID "#{perf[1]['crit6']}"
                xml.value {
                  xml.real "#{perf[1]['val6']}"
                }
              }
              xml.performance {
                xml.criterionID "#{perf[1]['crit7']}"
                xml.value {
                  xml.real "#{perf[1]['val7']}"
                }
              }
            }
          end
        }
      }
    end
    return builder.to_xml
  end

  def buildMethodparamsXML(mode, direction)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2012/XMCDA-2.2.0",
                         "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                         "xsi:schemaLocation" => "http://www.decision-deck.org/2012/XMCDA-2.2.0 http://www.decision-deck.org/xmcda/_downloads/XMCDA-2.2.0.xsd" ) {
        xml.methodParameters {
          case mode
            when 0
              xml.parent.namespace = nil
              xml.parameter(:name => "comparison_with") {
                xml.value {
                  xml.label 'alternatives'
                }
              }
            when 1
              xml.parent.namespace = nil
              xml.parameter(:name => "comparison_with") {
                xml.value {
                  xml.label 'alternatives'
                }
              }
              xml.parameter(:name => "use_pre_veto") {
                xml.value {
                  xml.boolean 'false'
                }
              }
            when 2
              xml.parent.namespace = nil
              xml.parameter(:name => "comparison_with") {
                xml.value {
                  xml.label 'alternatives'
                }
              }
              #important to set, otherwise other results
              xml.parameter(:name => "with_denominator") {
                xml.value {
                  xml.boolean 'true'
                }
              }
              xml.parameter(:name => "only_max_discordance") {
                xml.value {
                  xml.boolean 'false'
                }
              }
              xml.parameter(:name => "use_partials") {
                xml.value {
                  xml.boolean 'true'
                }
              }
            when 3
              xml.parent.namespace = nil
              xml.parameter(:name => "direction") {
                xml.value {
                  xml.label direction.to_s
                }
              }
              #important to set, otherwise other results
              xml.parameter(:name => "alpha") {
                xml.value {
                  xml.real '-0.15'
                }
              }
              xml.parameter(:name => "beta") {
                xml.value {
                  xml.real '0.3'
                }
              }
          end
        }
      }
    end
    return builder.to_xml
  end

  def buildWeightsXML
    weights = Hash.new()
    hashkey = 'c1'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c1'
    weights[hashkey]['weight'] = '0.3'
    hashkey = 'c2'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c2'
    weights[hashkey]['weight'] = '0.1'
    hashkey = 'c3'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c3'
    weights[hashkey]['weight'] = '0.3'
    hashkey = 'c4'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c4'
    weights[hashkey]['weight'] = '0.2'
    hashkey = 'c5'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c5'
    weights[hashkey]['weight'] = '0.1'
    hashkey = 'c6'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c6'
    weights[hashkey]['weight'] = '0.2'
    hashkey = 'c7'
    weights[hashkey] = Hash.new()
    weights[hashkey]['id'] = 'c7'
    weights[hashkey]['weight'] = '0.1'

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.title 'Weights'
          xml.comment_ 'weights of criteria'
        }
        xml.criteriaValues(:mcdaConcept => "Importance", :name => "significance"){
          xml.parent.namespace = nil
          weights.each_with_index do |weight, index|
            xml.criterionValue {
              xml.criterionID "#{weight[1]['id']}"
              xml.value {
                xml.real "#{weight[1]['weight']}"
              }
            }
          end
        }
      }
    end
    return builder.to_xml
  end

  def buildConcordanceXML(concordanceXML)
    return '<ns0:XMCDA xmlns:ns0="http://www.decision-deck.org/2009/XMCDA-2.1.0"><alternativesComparisons>' + concordanceXML + '</alternativesComparisons></ns0:XMCDA>'
  end

  def buildDiscordanceXML(discordanceXML)
    return '<ns0:XMCDA xmlns:ns0="http://www.decision-deck.org/2009/XMCDA-2.1.0"><alternativesComparisons>' + discordanceXML + '</alternativesComparisons></ns0:XMCDA>'
  end

  def buildCredibilityXML(credibilityXML)
    return '<xmcda:XMCDA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xmcda="http://www.decision-deck.org/2009/XMCDA-2.0.0" xsi:schemaLocation="http://www.decision-deck.org/2009/XMCDA-2.0.0 http://sma.uni.lu/d2cms/xmcda/_downloads/XMCDA-2.0.0.xsd">
<alternativesComparisons>' + credibilityXML + '</alternativesComparisons></xmcda:XMCDA>'
  end

end