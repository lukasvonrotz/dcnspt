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

    numberofcrits = params[:numberofcrits].to_i
    index = 1
    while index <= numberofcrits
      @project.criterionparams[index-1].filterlow = params[variablenamelow(index)]
      @project.criterionparams[index-1].filterhigh = params[variablenamehigh(index)]
      @project.criterionparams[index-1].save
      index += 1
    end

    @project.employees.delete_all
    fulfilled = 0
    Employee.all.each do |employee|
      @project.criterionparams.each do |criterionparam|
        if !employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).nil?
          criterionvalue = employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).value.to_f
          if criterionparam.filterlow <= criterionvalue && criterionparam.filterhigh >= criterionvalue
            fulfilled += 1
          end
        end
      end
      if numberofcrits == fulfilled
        @project.employees << employee
      end
      fulfilled = 0
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

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.title 'SixRealCars - Categories profiles'
          xml.comment_ 'Only the profiles and categories association, from the "SixRealCars" data set'
        }
        xml.categoriesProfiles{
          xml.parent.namespace = nil
          xml.categoryProfile {
            xml.alternativeID 'pMG'
            xml.limits {
              xml.lowerCategory {
                xml.categoryID 'Medium'
              }
              xml.upperCategory {
                xml.categoryID 'Good'
              }
            }
          }
          xml.categoryProfile {
            xml.alternativeID 'pBM'
            xml.limits {
              xml.lowerCategory {
                xml.categoryID 'Bad'
              }
              xml.upperCategory {
                xml.categoryID 'Medium'
              }
            }
          }
        }
      }
    end
    xml = builder.to_xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'

    soapmessage1 = Soapcreator.new
    soapmessage1.classes_profiles = xml_raw

    numAlternatives = 6
    numProfiles = 2
    concordance_alt = Array.new(numAlternatives){Array.new(numProfiles)}
    concordance_prof = Array.new(numProfiles){Array.new(numAlternatives)}
    partials = [0.7,0.976,0.3144,0.7549,0.654,1.0,0.5928,0.6453,0.6181,0.9766,0.3504,0.8809,0.7219,1.0 ,0.7891,0.829,1.0,0.874,0.3546,0.476,0.0846,0.49,0.24,0.356]

    alt_index = 0
    prof_index = 0

    partials.each_with_index do |pairvalue, index|
      puts '[' + alt_index.to_s + '][' + (index % 2).to_s + ']'
      concordance_alt[alt_index][prof_index] = pairvalue
      if (index % 2) == 0
        alt_index += 1
      end
    end
    puts concordance



    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0") {
        xml.alternativesComparisons("mcdaConcept" => "alternativesProfilesComparisons") {
          xml.parent.namespace = nil
          xml.pairs {
            xml.pair {
              xml.initial {
                xml.alternativeID 'a01'
              }
              xml.terminal {
                xml.alternativeID 'pMG'
              }
              xml.value {
                xml.real '0.7'
              }
            }
          }
        }
      }
    end
    xml = builder.to_xml
    puts xml
    xml = xml.gsub! '<', '&lt;'
    xml_raw = xml.gsub! '>', '&gt;'





    soapmessage1.concordance = '&lt;?xml version="1.0" encoding="UTF-8"?&gt;
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
      &lt;value&gt;
        &lt;real&gt;0.7&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.976&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.3144&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.7549&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.654&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;1.0&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.5928&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.6453&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.6181&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.9766&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.3504&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.8809&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.7219&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;1.0&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.7891&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.829&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;1.0&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.874&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a01&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.3546&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a02&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.476&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a03&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.0846&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a04&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.49&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a05&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.24&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
    &lt;pair&gt;
      &lt;initial&gt;
        &lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
      &lt;/initial&gt;
      &lt;terminal&gt;
        &lt;alternativeID&gt;a06&lt;/alternativeID&gt;
      &lt;/terminal&gt;
      &lt;value&gt;
        &lt;real&gt;0.356&lt;/real&gt;
      &lt;/value&gt;
    &lt;/pair&gt;
  &lt;/pairs&gt;
&lt;/alternativesComparisons&gt;
&lt;/xmcda:XMCDA&gt;'


    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['xmcda'].XMCDA("xmlns:xmcda" => "http://www.decision-deck.org/2009/XMCDA-2.1.0", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") {
        xml.projectReference {
          xml.parent.namespace = nil
          xml.comment_ 'Six real cars" data set. Thanks to Quantin Hayez for having gathered the data (from the manufacturers web sites). Transformed into XMCDA and published with his permission. Note that the weights and thresholds have been arbitrarily fixed.'
        }
        xml.alternatives {
          xml.parent.namespace = nil
          xml.alternative(:id => "a01", :name => "Audi A3")
          xml.alternative(:id => "a02", :name => "Audi A4")
          xml.alternative(:id => "a03", :name => "BMW 118")
          xml.alternative(:id => "a04", :name => "BMW 320")
          xml.alternative(:id => "a05", :name => "Volvo C30")
          xml.alternative(:id => "a06", :name => "Volvo S40")
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
    puts 'results:'
    puts output2
    puts 'end of results'



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
