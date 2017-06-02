# Controller for the electre algorithm
class ElectreController < ApplicationController

  # Include the methods from the electre_helper class
  include ElectreHelper

  # package for handling asynchronous requests / using web services
  require 'net/http'
  # package for handling xml files
  require 'nokogiri'

  skip_before_filter :verify_authenticity_token

  # Control logic for electre-view
  # GET /projects/:project_id/electre
  def index
    @project = Project.find(params[:project_id])
    @alpha = params[:alpha]
    @beta = params[:beta]

    # Create hash with all project alternatives (with employee id's)
    @alternatives = Hash.new()
    @alternatives = getProjectAlternatives(@alternatives, @project, true)

    # Create hash with all project criteria (and load related criterionparams)
    criteria = Hash.new()
    criteria = getProjectCriteria(criteria, @project)

    # Create hash with all project weights (load weights from related criterionparams)
    weights = Hash.new()
    weights = getProjectWeights(weights, @project)


    soapInstance = Soapcreator.new
    soapInstance.project = @project.id

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
    @alternatives = rankAlternatives(@alternatives, hashRanking)

    # sort alternatives based on rank
    @alternatives = @alternatives.sort_by{|x,y| y['rank'].to_i}.to_h

  end


  # Control logic for running sensitivity analysis
  # GET /projects/:project_id/electre
  def sensitivity

    @project = Project.find(params[:project_id])
    @alpha = params[:alpha]
    @beta = params[:beta]
    @iteration = params['iteration'].to_i

    # Create hash with all project alternatives (with employee codes)
    @alternatives = Hash.new()
    @alternatives = getProjectAlternatives(@alternatives, @project, false)

    # Create hash with all project criteria (and load related criterionparams)
    criteria = Hash.new()
    criteria = getProjectCriteriaSensitivity(criteria, @project, params, @iteration)

    # Create hash with all project weights (load weights from related criterionparams)
    weights = Hash.new()
    weights = getProjectWeightsSensitivity(weights, @project, params, @iteration)


    soapInstance = Soapcreator.new
    soapInstance.project = @project.id

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
    @alternatives = rankAlternatives(@alternatives, hashRanking)

    @alternatives = @alternatives.sort_by{|x,y| y['rank'].to_i}.to_h
    # Additionally set the number of the actual iteration
    @alternatives['iteration'] = params['iteration']

    # response is to be in json-format
    respond_to do |format|
      format.html {
        render :json => @alternatives
      }
    end
  end

  # The user has the possibility to save the definded parameters for the sensitivity analysis.
  # Hence, if the project is reloaded, all defined parameters for each iterations can be loaded from the database.
  # GET /projects/:project_id/save-sensitivity-params
  def saveSensitivityParams
    # Destroy all project related sensitivity parameters that are in the database
    Sensitivity.where(:project_id => params[:project_id]).destroy_all
    @project = Project.find(params[:project_id])
    @project.criterionparams.each do |criterionparam|
      # Read out all sensitivity parameters from the HIDDEN fields
      weight_array = params['hidden_weight' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      indslo_array = params['hidden_inthresslo' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      indint_array = params['hidden_inthresint' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      prefslo_array = params['hidden_prefthresslo' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      prefint_array = params['hidden_prefthresint' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      vetslo_array = params['hidden_vetothresslo' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      vetint_array = params['hidden_vetothresint' + criterionparam.criterion.id.to_s].split(",").map(&:strip);
      i = 0
      # Save all new sensitivity parameters to the database
      while i < weight_array.length do
        @sensitivity = Sensitivity.new(:project_id => params[:project_id],
                                       :criterion_id => criterionparam.criterion.id,
                                       :weight => weight_array[i] == 'none' ? nil : weight_array[i],
                                       :indslo => indslo_array[i] == 'none' ? nil : indslo_array[i],
                                       :indint => indint_array[i] == 'none' ? nil : indint_array[i],
                                       :prefslo => prefslo_array[i] == 'none' ? nil : prefslo_array[i],
                                       :prefint => prefint_array[i] == 'none' ? nil : prefint_array[i],
                                       :vetslo => vetslo_array[i] == 'none' ? nil : vetslo_array[i],
                                       :vetint => vetint_array[i] == 'none' ? nil : vetint_array[i]
        )
        @sensitivity.save
        i+=1
      end

    end
    redirect_to projects_path + '/' + params[:project_id].to_s + '/electre?alpha=-0.15&beta=0.3'
  end

end
