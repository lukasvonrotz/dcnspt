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

    testxml = '<SOAP-ENV:Envelope xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ZSI="http://www.zolera.com/schemas/ZSI/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <SOAP-ENV:Header></SOAP-ENV:Header>
              <SOAP-ENV:Body>
                <alternatives>
                  <alternative id="a01" name="Audi A3" />
                  <alternative id="a02" name="Audi A4" />
                  <alternative id="a03" name="BMW 118" />
                  <alternative id="a04" name="BMW 320" />
                  <alternative id="a05" name="Volvo C30" />
                  <alternative id="a06" name="Volvo S40" />
                </alternatives>
              </SOAP-ENV:Body>
              </SOAP-ENV:Envelope>'

    puts post_xml(testxml)

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
