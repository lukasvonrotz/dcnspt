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

    numberOfServiceTries = 10

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
    puts 'concordance: try nr. 1'
    xml = buildSoapRequestConcordance(concordanceInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'concordance: try nr. ' + i.to_s
      xml = buildSoapRequestConcordance(concordanceInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform concordance web service!'
    else
      puts 'SUCCESS: successfully performed concordance web service!'
    end
    xmlConcordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ####buildSoapRequestDiscordance#####
    discordanceInput = soapInstance.getSoapDiscordance(criteria,weights)
    puts 'discordance: try nr. 1'
    xml = buildSoapRequestDiscordance(discordanceInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'discordance: try nr. ' + i.to_s
      xml = buildSoapRequestDiscordance(discordanceInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform discordance web service!'
    else
      puts 'SUCCESS: successfully performed discordance web service!'
    end
    xmlDiscordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ####buildSoapRequestDistillations#####
    credibilityInput = soapInstance.getSoapCredibility(xmlConcordance, xmlDiscordance)
    puts 'credibility: try nr. 1'
    xml = buildSoapRequestCredibility(credibilityInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'credibility: try nr. ' + i.to_s
      xml = buildSoapRequestCredibility(credibilityInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform credibility web service!'
    else
      puts 'SUCCESS: successfully performed credibility web service!'
    end
    credibilityXML = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')


    ####buildSoapRequestDistillations#####

    ######downwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'downwards', @alpha, @beta)
    xml = buildSoapRequestDistillation(distillationInput)
    puts 'distillation downwards: try nr. 1'
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'distillation downwards: try nr. ' + i.to_s
      xml = buildSoapRequestDistillation(distillationInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform distillation downwards web service!'
    else
      puts 'SUCCESS: successfully performed distillation downwards web service!'
    end
    downwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')

    ######upwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'upwards', @alpha, @beta)
    puts 'distillation upwards: try nr. 1'
    xml = buildSoapRequestDistillation(distillationInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'distillation upwards: try nr. ' + i.to_s
      xml = buildSoapRequestDistillation(distillationInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform distillation upwards web service!'
    else
      puts 'SUCCESS: successfully performed distillation upwards web service!'
    end
    upwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')


    ####buildSoapRequestRanking#####
    rankingInput = soapInstance.getSoapRanking(downwardsXML, upwardsXML)
    puts 'ranking: try nr. 1'
    xml = buildSoapRequestRanking(rankingInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'ranking: try nr. ' + i.to_s
      xml = buildSoapRequestRanking(rankingInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform ranking web service!'
    else
      puts 'SUCCESS: successfully performed ranking web service!'
    end
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

    numberOfServiceTries = 10

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
    puts 'concordance: try nr. 1'
    xml = buildSoapRequestConcordance(concordanceInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'concordance: try nr. ' + i.to_s
      xml = buildSoapRequestConcordance(concordanceInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform concordance web service!'
    else
      puts 'SUCCESS: successfully performed concordance web service!'
    end
    xmlConcordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ###buildSoapRequestDiscordance#####
    discordanceInput = soapInstance.getSoapDiscordance(criteria,weights)
    puts 'discordance: try nr. 1'
    xml = buildSoapRequestDiscordance(discordanceInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'discordance: try nr. ' + i.to_s
      xml = buildSoapRequestDiscordance(discordanceInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform discordance web service!'
    else
      puts 'SUCCESS: successfully performed discordance web service!'
    end
    xmlDiscordance = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')

    ####buildSoapRequestDistillations#####
    credibilityInput = soapInstance.getSoapCredibility(xmlConcordance, xmlDiscordance)
    puts 'credibility: try nr. 1'
    xml = buildSoapRequestCredibility(credibilityInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'credibility: try nr. ' + i.to_s
      xml = buildSoapRequestCredibility(credibilityInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform credibility web service!'
    else
      puts 'SUCCESS: successfully performed credibility web service!'
    end
    credibilityXML = convertXML(xml,'<alternativesComparisons>','</alternativesComparisons>')


    ####buildSoapRequestDistillations#####

    ######downwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'downwards', @alpha, @beta)
    puts 'distillation downwards: try nr. 1'
    xml = buildSoapRequestDistillation(distillationInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'distillation downwards: try nr. ' + i.to_s
      xml = buildSoapRequestDistillation(distillationInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform distillation downwards web service!'
    else
      puts 'SUCCESS: successfully performed distillation downwards web service!'
    end
    downwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')

    ######upwards#######################
    distillationInput = soapInstance.getSoapDistillation(credibilityXML,'upwards', @alpha, @beta)
    puts 'distillation upwards: try nr. 1'
    xml = buildSoapRequestDistillation(distillationInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'distillation upwards: try nr. ' + i.to_s
      xml = buildSoapRequestDistillation(distillationInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform distillation upwards web service!'
    else
      puts 'SUCCESS: successfully performed distillation upwards web service!'
    end
    upwardsXML = convertXML(xml,'<alternativesValues>','</alternativesValues>')


    ####buildSoapRequestRanking#####
    rankingInput = soapInstance.getSoapRanking(downwardsXML, upwardsXML)
    puts 'ranking: try nr. 1'
    xml = buildSoapRequestRanking(rankingInput)
    i = 2
    while xml.nil? && i <= numberOfServiceTries
      puts 'ranking: try nr. ' + i.to_s
      xml = buildSoapRequestRanking(rankingInput)
      i += 1
    end
    if xml.nil?
      puts 'ERROR: could not perform ranking web service!'
    else
      puts 'SUCCESS: successfully performed ranking web service!'
    end
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
