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


        #if all criteria are fulfilled
        if numberofcrits == fulfilled
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


    soapmessage1 = Soapcreator.new
    numAlternatives = 6
    numProfiles = 2


    categoriesProfiles = Hash.new()
    categoriesProfiles['prof1'] = Hash.new()
    categoriesProfiles['prof1']['aid'] = 'pMG'
    categoriesProfiles['prof1']['lowcat'] = 'Medium'
    categoriesProfiles['prof1']['upcat'] = 'Good'
    categoriesProfiles['prof2'] = Hash.new()
    categoriesProfiles['prof2']['aid'] = 'pBM'
    categoriesProfiles['prof2']['lowcat'] = 'Bad'
    categoriesProfiles['prof2']['upcat'] = 'Medium'

    alternatives = Hash.new()
    alternatives['alt1'] = Hash.new()
    alternatives['alt1']['id'] = 'a01'
    alternatives['alt1']['name'] = 'Audi A3'
    alternatives['alt2'] = Hash.new()
    alternatives['alt2']['id'] = 'a02'
    alternatives['alt2']['name'] = 'Audi A4'
    alternatives['alt3'] = Hash.new()
    alternatives['alt3']['id'] = 'a03'
    alternatives['alt3']['name'] = 'BMW 118'
    alternatives['alt4'] = Hash.new()
    alternatives['alt4']['id'] = 'a04'
    alternatives['alt4']['name'] = 'BMW 320'
    alternatives['alt5'] = Hash.new()
    alternatives['alt5']['id'] = 'a05'
    alternatives['alt5']['name'] = 'Volvo C30'
    alternatives['alt6'] = Hash.new()
    alternatives['alt6']['id'] = 'a06'
    alternatives['alt6']['name'] = 'Volvo S40'



    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.title 'SixRealCars - Categories profiles'
          xml.comment_ 'Only the profiles and categories association, from the "SixRealCars" data set'
        }
        xml.categoriesProfiles{
          xml.parent.namespace = nil
          categoriesProfiles.each do |prof|
            xml.categoryProfile {
              xml.alternativeID "#{prof[1]['aid']}"
              xml.limits {
                xml.lowerCategory {
                  xml.categoryID "#{prof[1]['lowcat']}"
                }
                xml.upperCategory {
                  xml.categoryID "#{prof[1]['upcat']}"
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
    soapmessage1.classes_profiles = xml_raw




    concordance_alt = Array.new(numAlternatives){Array.new(numProfiles)}
    concordance_prof = Array.new(numProfiles){Array.new(numAlternatives)}
    partials = [0.7,0.976,0.3144,0.7549,0.654,1.0,0.5928,0.6453,0.6181,0.9766,0.3504,0.8809,0.7219,1.0 ,0.7891,0.829,1.0,0.874,0.3546,0.476,0.0846,0.49,0.24,0.356]
    alt_index = 0
    alt_index2 = 0
    prof_index2 = 0
    array = Array.new
    partials.each_with_index do |pairvalue, index|
      if index < numAlternatives*numProfiles
        array.push pairvalue
        if (((index+1)%numProfiles) == 0)
          concordance_alt[alt_index] = array
          array = Array.new
          alt_index += 1
        end
      else
        array.push pairvalue
        if (((index+1)-(numAlternatives*numProfiles)) % numAlternatives) == 0
          concordance_prof[prof_index2] = array
          array = Array.new
          prof_index2 += 1
          alt_index2 = 0
        else
          alt_index2 += 1
        end
      end
    end
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2012/XMCDA-2.2.0",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://www.decision-deck.org/2012/XMCDA-2.2.0 http://www.decision-deck.org/xmcda/_downloads/XMCDA-2.2.0.xsd") {
        xml.alternativesComparisons("mcdaConcept" => "alternativesProfilesComparisons") {
          xml.parent.namespace = nil
          xml.pairs {
            alternatives.each_with_index do |alt, index|
              categoriesProfiles.each_with_index.each_with_index do |cat, index1|
                xml.pair {
                  xml.initial {
                    xml.alternativeID alt[1]['id']
                  }
                  xml.terminal {
                    xml.alternativeID cat[0][1]['aid']
                  }
                  xml.value {
                    xml.real concordance_alt[index][index1]
                  }
                }
              end
            end
            categoriesProfiles.each_with_index do |cat, index|
              alternatives.each_with_index.each_with_index do |alt, index1|
                xml.pair {
                  xml.initial {
                    xml.alternativeID cat[1]['aid']
                  }
                  xml.terminal {
                    xml.alternativeID alt[0][1]['id']
                  }
                  xml.value {
                    xml.real concordance_prof[index][index1]
                  }
                }
              end
            end
          }
        }
      }
    end
    xml = builder.to_xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.concordance = xml_raw






    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.comment_ 'Six real cars" data set. Thanks to Quantin Hayez for having gathered the data (from the manufacturers web sites). Transformed into XMCDA and published with his permission. Note that the weights and thresholds have been arbitrarily fixed.'
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
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.alternatives = xml_raw





    soapmessage1.discordance = '&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;xmcda:XMCDA xmlns:xmcda="http://www.decision-deck.org/2012/XMCDA-2.2.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.decision-deck.org/2012/XMCDA-2.2.0 http://www.decision-deck.org/xmcda/_downloads/XMCDA-2.2.0.xsd"&gt;
&lt;alternativesComparisons mcdaConcept="alternativesProfilesComparisons"&gt;
  &lt;pairs&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;1&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;1&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;1&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;1&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;1&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;1&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;values&gt;
        &lt;value id="c01"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c02"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c03"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c04"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
        &lt;value id="c05"&gt;
          &lt;real&gt;0&lt;/real&gt;
        &lt;/value&gt;
      &lt;/values&gt;
    &lt;/pair&gt;
  &lt;/pairs&gt;
&lt;/alternativesComparisons&gt;
&lt;/xmcda:XMCDA&gt;'



    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2012/XMCDA-2.2.0",
                         "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                         "xsi:schemaLocation" => "http://www.decision-deck.org/2012/XMCDA-2.2.0 http://www.decision-deck.org/xmcda/_downloads/XMCDA-2.2.0.xsd" ) {
        xml.methodParameters {
          xml.parent.namespace = nil
          xml.parameter(:name => "comparison_with") {
            xml.value {
              xml.label 'boundary_profiles'
            }
          }
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
        }
      }
    end
    xml = builder.to_xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'
    soapmessage1.method_parameters = xml_raw



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
    params.require(:project).permit(:name, :loclat, :loclon, :startdate, :enddate, :effort, :hourlyrate, {:criterion_ids => []}, {:employee_ids => []})
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
    host = "http://webservices.decision-deck.org/soap/ElectreCredibility-PUT.py"
    uri = URI.parse host
    request = Net::HTTP::Post.new uri.path
    request.body = xml
    request.content_type = 'application/soap+xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    return response.body
  end

end
