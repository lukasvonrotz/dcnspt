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

    #@client = Savon.client do
    #  wsdl "http://webservices.decision-deck.org/soap/ElectreDistillation-PUT.py",
    #  basic_auth {[ 'username', 'password' ]},
    #  log "true",
    #  log_level "debug",
    #  pretty_print_xml "true"
    #end

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.alternatives {
        xml.alternative  {
          xml.id_ "x1"
          xml.value "0"
        }
        xml.alternative {
          xml.id_ "x4"
          xml.value "1"
        }
      }
    end

    soapmessage1 = Soapcreator.new

    soapmessage1.classes_profiles = '<classes_profiles xsi:type="xsd:string">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;xmcda:XMCDA xmlns:xmcda="http://www.decision-deck.org/2009/XMCDA-2.1.0"&gt;
	&lt;projectReference&gt;
		&lt;title&gt;SixRealCars - Categories profiles&lt;/title&gt;
		&lt;comment&gt;Only the profiles and categories association, from the "SixRealCars" data set.&lt;/comment&gt;
	&lt;/projectReference&gt;
	&lt;categoriesProfiles&gt;
		&lt;categoryProfile&gt;
			&lt;alternativeID&gt;pMG&lt;/alternativeID&gt;
			&lt;limits&gt;
				&lt;lowerCategory&gt;
					&lt;categoryID&gt;Medium&lt;/categoryID&gt;
				&lt;/lowerCategory&gt;
				&lt;upperCategory&gt;
					&lt;categoryID&gt;Good&lt;/categoryID&gt;
				&lt;/upperCategory&gt;
			&lt;/limits&gt;
		&lt;/categoryProfile&gt;
		&lt;categoryProfile&gt;
			&lt;alternativeID&gt;pBM&lt;/alternativeID&gt;
			&lt;limits&gt;
				&lt;lowerCategory&gt;
					&lt;categoryID&gt;Bad&lt;/categoryID&gt;
				&lt;/lowerCategory&gt;
				&lt;upperCategory&gt;
					&lt;categoryID&gt;Medium&lt;/categoryID&gt;
				&lt;/upperCategory&gt;
			&lt;/limits&gt;
		&lt;/categoryProfile&gt;
	&lt;/categoriesProfiles&gt;
&lt;/xmcda:XMCDA&gt;</classes_profiles>'

    soapmessage1.concordance = '<concordance xsi:type="xsd:string">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
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
&lt;/xmcda:XMCDA&gt;</concordance>'

    soapmessage1.alternatives = '<alternatives xsi:type="xsd:string">&lt;xmcda:XMCDA xmlns:xmcda="http://www.decision-deck.org/2009/XMCDA-2.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;
	&lt;projectReference&gt;
		&lt;comment&gt;"Six real cars" data set. Thanks to Quantin Hayez for having gathered
		the data (from the manufacturers web sites). Transformed into XMCDA
		and published with his permission. Note that the weights and thresholds have been
		arbitrarily fixed.&lt;/comment&gt;
	&lt;/projectReference&gt;

	&lt;alternatives&gt;
		&lt;alternative id="a01" name="Audi A3" /&gt;
		&lt;alternative id="a02" name="Audi A4" /&gt;
		&lt;alternative id="a03" name="BMW 118" /&gt;
		&lt;alternative id="a04" name="BMW 320" /&gt;
		&lt;alternative id="a05" name="Volvo C30" /&gt;
		&lt;alternative id="a06" name="Volvo S40" /&gt;
	&lt;/alternatives&gt;

&lt;/xmcda:XMCDA&gt;
  </alternatives>'

    soapmessage1.discordance = '<discordance xsi:type="xsd:string">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
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
&lt;/xmcda:XMCDA&gt;
</discordance>'

    soapmessage1.method_parameters = '<method_parameters xsi:type="xsd:string">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;xmcda:XMCDA xmlns:xmcda="http://www.decision-deck.org/2012/XMCDA-2.2.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.decision-deck.org/2012/XMCDA-2.2.0 http://www.decision-deck.org/xmcda/_downloads/XMCDA-2.2.0.xsd"&gt;

&lt;methodParameters&gt;
  &lt;parameter name="comparison_with"&gt;
    &lt;value&gt;
      &lt;label&gt;boundary_profiles&lt;/label&gt;
    &lt;/value&gt;
  &lt;/parameter&gt;
  &lt;parameter name="with_denominator"&gt;
    &lt;value&gt;
      &lt;boolean&gt;true&lt;/boolean&gt;
    &lt;/value&gt;
  &lt;/parameter&gt;
  &lt;parameter name="only_max_discordance"&gt;
    &lt;value&gt;
      &lt;boolean&gt;false&lt;/boolean&gt;
    &lt;/value&gt;
  &lt;/parameter&gt;
  &lt;parameter name="use_partials"&gt;
    &lt;value&gt;
      &lt;boolean&gt;true&lt;/boolean&gt;
    &lt;/value&gt;
  &lt;/parameter&gt;
&lt;/methodParameters&gt;

&lt;/xmcda:XMCDA&gt;
</method_parameters>'


    testxml1 = Soapcreator.get_header +
        soapmessage1.classes_profiles + soapmessage1.concordance + soapmessage1.alternatives + soapmessage1.discordance + soapmessage1.method_parameters +
        Soapcreator.get_footer

    output1 = Nokogiri::XML(post_xml(testxml1))
    puts output1
    ticket = output1.xpath("//ticket/text()").to_s

    testxml2 = '<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
  SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
  xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
  xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"
  xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
  xmlns:xsd="http://www.w3.org/1999/XMLSchema"
>
<SOAP-ENV:Body>
<requestSolution SOAP-ENC:root="1">
<ticket xsi:type="xsd:string">' + ticket + '</ticket>
</requestSolution>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>'

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
