class Soapcreator

  attr_accessor :project, :alternatives, :criteria, :performance, :method_parameters, :weights,
                :concordance, :discordance, :credibility, :downwards, :upwards

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
  @@downwardsheader = '<downwards xsi:type="xsd:string">'
  @@downwardsfooter = '</downwards>'
  @@upwardsheader = '<upwards xsi:type="xsd:string">'
  @@upwardsfooter = '</upwards>'
  @@weightsheader = '<weights xsi:type="xsd:string">'
  @@weightsfooter = '</weights>'







  def getSoapConcordance(criteria,weights)

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(0)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######criteria######
    xml = buildCriteriaXML(criteria)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @criteria = xml_raw

    ########performance#########
    xml = buildPerformanceXML
    puts xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @performance = xml_raw

    ######method_parameter######
    xml  = buildMethodparamsXML(0,'','','')
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw


    ##########weights###########
    xml = buildWeightsXML(weights)
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

  def getSoapDiscordance(criteria,weights)

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(0)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######criteria######
    xml = buildCriteriaXML(criteria)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @criteria = xml_raw

    ########performance#########
    xml = buildPerformanceXML
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @performance = xml_raw

    ######method_parameter######
    xml  = buildMethodparamsXML(1,'','','')
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw


    ##########weights###########
    xml = buildWeightsXML(weights)
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
    xml  = buildMethodparamsXML(2,'','','')
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

  def getSoapDistillation(credibilityXML, direction, alpha, beta)

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
    xml  = buildMethodparamsXML(3,direction, alpha, beta)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @method_parameters = xml_raw


    return @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@credibilityheader.to_s + @credibility.to_s + @@credibilityfooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
        @@soapfooter.to_s
  end

  def getSoapRanking(downwardsXML, upwardsXML)

    ####buildSOAPMsg####

    ####alternatives####
    xml = buildAlternativesXML(1)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @alternatives = xml_raw

    ######downwards######
    xml = buildDownwardsXML(downwardsXML)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @downwards = xml_raw

    ######upwards######
    xml = buildUpwardsXML(upwardsXML)
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    @upwards = xml_raw


    return @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@downwardsheader.to_s + @downwards.to_s + @@downwardsfooter.to_s +
        @@upwardsheader.to_s + @upwards.to_s + @@upwardsfooter.to_s +
        @@soapfooter.to_s
  end







  def self.getSoapTicket(ticket)
    @@soapheader_ticket.to_s +
        '<ticket xsi:type="xsd:string">' + ticket + '</ticket>' +
        @@soapfooter_ticket.to_s
  end

  def buildAlternativesXML(mode)
    alternatives = Hash.new()
    Project.find(@project).employees.each_with_index do |employee, index|
      hashkey = 'alt' + (index+1).to_s
      alternatives[hashkey] = Hash.new()
      alternatives[hashkey]['id'] = 'a' + (index + 1).to_s
      alternatives[hashkey]['name'] = employee.firstname + ' ' + employee.surname
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
              xml.comment_ 'All users that are considered for the electre iii algorithm'
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

  def buildCriteriaXML(criteria)

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
    actualProject = Project.find(@project)
    actualProject.employees.each_with_index do |employee, index|
      hashkey = 'a' + (index+1).to_s
      performance[hashkey] = Hash.new()
      performance[hashkey]['id'] = 'a' + (index+1).to_s
      actualProject.criterions.each_with_index do |criterion, index|
        cstring = 'crit' + (index+1).to_s
        vstring = 'val' + (index+1).to_s
        performance[hashkey][cstring] = 'c' + (index+1).to_s
        if !Criterionvalue.where(:criterion_id => criterion.id, :employee_id => employee.id)[0].nil?
          performance[hashkey][vstring] = Criterionvalue.where(:criterion_id => criterion.id, :employee_id => employee.id)[0].value.to_s
        else
          if criterion.id == 1
            performance[hashkey][vstring] = Location.get_distance(employee.loclat,employee.loclon,actualProject.loclat,actualProject.loclon)
          elsif criterion.id == 2
            performance[hashkey][vstring] = Margin.get_margin(actualProject.hourlyrate,employee.costrate)
          else
            performance[hashkey][vstring] = 0
          end
        end
      end
    end


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
              Project.find(@project).criterions.each_with_index do |criterion, index|
                critstring = 'crit' + (index+1).to_s
                valstring = 'val' + (index+1).to_s
              xml.performance {
                xml.criterionID "#{perf[1][critstring]}"
                xml.value {
                  xml.real "#{perf[1][valstring]}"
                }
              }
              end
            }
          end
        }
      }
    end
    return builder.to_xml
  end

  def buildMethodparamsXML(mode, direction, alpha, beta)
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

  def buildWeightsXML(weights)
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

  def buildDownwardsXML(downwardsXML)
    return '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xmcdaXSL.xsl"?>
<xmcda:XMCDA xmlns:xmcda="http://www.decision-deck.org/2009/XMCDA-2.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.decision-deck.org/2009/XMCDA-2.0.0 http://sma.uni.lu/d2cms/xmcda/_downloads/XMCDA-2.0.0.xsd">
<alternativesValues mcdaConcept="downwards_distillation">' + downwardsXML + '</alternativesValues></xmcda:XMCDA>'
  end

  def buildUpwardsXML(upwardsXML)
    return '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xmcdaXSL.xsl"?>
<xmcda:XMCDA xmlns:xmcda="http://www.decision-deck.org/2009/XMCDA-2.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.decision-deck.org/2009/XMCDA-2.0.0 http://sma.uni.lu/d2cms/xmcda/_downloads/XMCDA-2.0.0.xsd">
<alternativesValues mcdaConcept="upwards_distillation">' + upwardsXML + '</alternativesValues></xmcda:XMCDA>'
  end

end