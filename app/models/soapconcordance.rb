class Soapconcordance

  attr_accessor :alternatives, :criteria, :performance, :method_parameters, :weights

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
  @@performanceheader = '<performance_table xsi:type="xsd:string">'
  @@performancefooter = '</performance_table>'
  @@method_parametersheader = '<method_parameters xsi:type="xsd:string">'
  @@method_parametersfooter = '</method_parameters>'
  @@weightsheader = '<weights xsi:type="xsd:string">'
  @@weightsfooter = '</weights>'


  def get_soaprequest
    @@soapheader.to_s +
        @@alternativesheader.to_s + @alternatives.to_s + @@alternativesfooter.to_s +
        @@criteriaheader.to_s + @criteria.to_s + @@criteriafooter.to_s +
        @@performanceheader.to_s + @performance.to_s + @@performancefooter.to_s +
        @@method_parametersheader.to_s + @method_parameters.to_s + @@method_parametersfooter.to_s +
        @@weightsheader.to_s + @weights.to_s + @@weightsfooter.to_s +
      @@soapfooter.to_s
  end

  def self.get_soaprequest_ticket(ticket)
    @@soapheader_ticket.to_s +
      '<ticket xsi:type="xsd:string">' + ticket + '</ticket>' +
    @@soapfooter_ticket.to_s
  end

end
