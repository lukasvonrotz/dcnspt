class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  require 'net/http'
  require 'nokogiri'

  def new
    # build a 'temporary' post which is written to DB later (create-method)
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    # write project to database
    if @project.save
      redirect_to projects_path, :notice => 'Project successufully created'
    else
      render 'new'
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    if params[:id]
      @project = Project.find(params[:id])
    else
      @project = Project.find(params[:project_id])
    end

    if !params[:numberofcrits].nil?
      jobprofiles = project_params[:jobprofile_list].split(', ')
      numberofcrits = params[:numberofcrits].to_i
      index = 1

      while index <= numberofcrits
        @project.criterionparams[index-1].filterlow = params[variablenamelow(index)]
        @project.criterionparams[index-1].filterhigh = params[variablenamehigh(index)]
        @project.criterionparams[index-1].save
        index += 1
      end
      index = 1
      while index <= numberofcrits
        index += 1
      end
      @project.employees.delete_all
      fulfilled = 0
      Employee.all.each do |employee|
        @project.criterionparams.each do |criterionparam|
          if !employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).nil?
            criterionvalue = employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).value.to_f
            if (criterionparam.filterlow <= criterionvalue) && (criterionparam.filterhigh >= criterionvalue)
              fulfilled += 1
            end
          end
        end

        #check additionally if costrate and location is fulfilled (because they are not saved in the criterion values)
        locationid = Criterion.where(name: 'location').first.id
        costrateid = Criterion.where(name: 'costrate').first.id
        if @project.criterionparams.exists?(:criterion_id => locationid) && @project.criterionparams.exists?(:criterion_id => costrateid)
          distance = Location.get_distance(employee.loclat,employee.loclon,@project.loclat,@project.loclon)
          costrate = employee.costrate
          if (Criterionparam.where(criterion_id: locationid).first.filterlow <= distance) && (Criterionparam.where(criterion_id: locationid).first.filterhigh >= distance)
            fulfilled += 1
          end
          if (Criterionparam.where(criterion_id: costrateid).first.filterlow <= costrate) && (Criterionparam.where(criterion_id: costrateid).first.filterhigh >= costrate)
            fulfilled += 1
          end
        end

        #if all criteria are fulfilled && job profile does also match
        if ((numberofcrits == fulfilled) && (jobprofiles.include? employee.jobprofile))
          @project.employees << employee
        end
        fulfilled = 0
      end
    end

    if @project.update(project_params)
      redirect_to @project, :notice => 'Project successfully updated'
    else
      render 'edit'
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def index
    @projects = Project.all


    soapmessage1 = Soapconcordance.new
    numAlternatives = 6
    numProfiles = 2



####################
####alternatives####
####################

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
    end
    xml = builder.to_xml
    puts xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.alternatives = xml_raw




####################
######criteria######
####################

    criteria = Hash.new()
    hashkey = 'crit1'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c1'
    criteria[hashkey]['name'] = 'Price'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indifference'] = '500'
    criteria[hashkey]['preference'] = '3000'
    criteria[hashkey]['veto'] = '4000'
    hashkey = 'crit2'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c2'
    criteria[hashkey]['name'] = 'Vmax'
    criteria[hashkey]['direction'] = 'max'
    criteria[hashkey]['indifference'] = '0.0'
    criteria[hashkey]['preference'] = '30.0'
    hashkey = 'crit3'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c3'
    criteria[hashkey]['name'] = 'C120'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indifference'] = '0.0'
    criteria[hashkey]['preference'] = '2.0'
    hashkey = 'crit4'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c4'
    criteria[hashkey]['name'] = 'Coff'
    criteria[hashkey]['direction'] = 'max'
    criteria[hashkey]['indifference'] = '0.0'
    criteria[hashkey]['preference'] = '1.0'
    hashkey = 'crit5'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c5'
    criteria[hashkey]['name'] = 'Acc'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indifference'] = '0.0'
    criteria[hashkey]['preference'] = '100.0'
    hashkey = 'crit6'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c6'
    criteria[hashkey]['name'] = 'Frei'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indifference'] = '0.0'
    criteria[hashkey]['preference'] = '100.0'
    hashkey = 'crit7'
    criteria[hashkey] = Hash.new()
    criteria[hashkey]['id'] = 'c7'
    criteria[hashkey]['name'] = 'Brui'
    criteria[hashkey]['direction'] = 'min'
    criteria[hashkey]['indifference'] = '0.0'
    criteria[hashkey]['preference'] = '100.0'

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.title 'All relevant criteria'
          xml.comment_ 'Only the relevant criteria for the project'
        }
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
                  if criterion[1]['indifference']
                    xml.threshold(:mcdaConcept => "indifference") {
                      xml.constant {
                        xml.real "#{criterion[1]['indifference']}"
                      }
                    }
                  end
                  if criterion[1]['preference']
                  xml.threshold(:mcdaConcept => "preference") {
                    xml.constant {
                      xml.real "#{criterion[1]['preference']}"
                    }
                  }
                  end
                  if criterion[1]['veto']
                  xml.threshold(:mcdaConcept => "veto") {
                    xml.constant {
                      xml.real "#{criterion[1]['veto']}"
                    }
                  }
                  end
                }
              }
            end
        }
      }
    end
    xml = builder.to_xml
    puts xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.criteria = xml_raw




############################
########performance#########
############################

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
    xml = builder.to_xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.performance = xml_raw




############################
######method_parameter######
############################

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2012/XMCDA-2.2.0",
                         "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                         "xsi:schemaLocation" => "http://www.decision-deck.org/2012/XMCDA-2.2.0 http://www.decision-deck.org/xmcda/_downloads/XMCDA-2.2.0.xsd" ) {
        xml.methodParameters {
          xml.parent.namespace = nil
          xml.parameter(:name => "comparison_with") {
            xml.value {
              xml.label 'alternatives'
            }
          }
        }
      }
    end
    xml = builder.to_xml
    puts xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.method_parameters = xml_raw




############################
##########weights###########
############################


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
    xml = builder.to_xml
    puts xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.weights = xml_raw




    testxml1 = soapmessage1.get_soaprequest
    output1 = Nokogiri::XML(post_xml(testxml1))
    testxml2 = Soapcreator.get_soaprequest_ticket(output1.xpath("//ticket/text()").to_s)
    output2 = Nokogiri::XML(post_xml(testxml2))
    puts output2


  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, :notice => 'Project deleted'
  end

  def filter
    @project = Project.find(params[:project_id])
  end

  def updateemployees

  end


  private
  # defines which parameters have to be provided by the form when creating a new project
  def project_params
    params.require(:project).permit(:name, :loclat, :loclon, :startdate, :enddate, :effort, :hourlyrate, {:criterion_ids => []}, {:employee_ids => []}, :jobprofile_list)
  end

  def variablenamelow (index)
    var = "crit" + index.to_s + "low"
    return var
  end

  def variablenamehigh (index)
    var = "crit" + index.to_s + "high"
    return var
  end

  def post_xml(xml)
    host = "http://webservices.decision-deck.org/soap/ElectreConcordanceReinforcedPreference-PUT.py"
    uri = URI.parse host
    request = Net::HTTP::Post.new uri.path
    request.body = xml
    request.content_type = 'application/soap+xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    return response.body
  end

end
