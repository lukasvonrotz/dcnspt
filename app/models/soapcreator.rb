class Soapcreator

  attr_accessor :alternatives, :classes_profiles, :concordance, :discordance, :method_parameters

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


  @@classes_profilesheader = '<classes_profiles xsi:type="xsd:string">'
  @@classes_profilesfooter = '</classes_profiles>'
  @@alternativesheader = '<alternatives xsi:type="xsd:string">'
  @@alternativesfooter = '</alternatives>'
  @@concordanceheader = '<concordance xsi:type="xsd:string">'
  @@concordancefooter = '</concordance>'
  @@discordanceheader = '<discordance xsi:type="xsd:string">'
  @@discordancefooter = '</discordance>'
  @@method_parametersheader = '<method_parameters xsi:type="xsd:string">'
  @@method_parametersfooter = '</method_parameters>'


  def get_soaprequest
    @@soapheader.to_s +
        @@classes_profilesheader.to_s + @classes_profiles.to_s + @@classes_profilesfooter.to_s +
        @@concordanceheader.to_s + @concordance.to_s + @@concordancefooter.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@discordanceheader.to_s + @discordance.to_s + @@discordancefooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
      @@soapfooter.to_s
  end

  def self.get_soaprequest_ticket(ticket)
    @@soapheader_ticket.to_s +
      '<ticket xsi:type="xsd:string">' + ticket + '</ticket>' +
    @@soapfooter_ticket.to_s
  end

end
