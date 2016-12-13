class Soapcreator

  attr_accessor :header, :alternatives, :classes_profiles, :concordance, :discordance, :method_parameters, :footer

  @@header = '<SOAP-ENV:Envelope
        SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"
        xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/1999/XMLSchema"
      >
      <SOAP-ENV:Body>
      <submitProblem SOAP-ENC:root="1">'

  @@footer =
      '</submitProblem>
       </SOAP-ENV:Body>
       </SOAP-ENV:Envelope>'

  def self.get_header
    return @@header
  end

  def self.get_footer
    return @@footer
  end

  def self.get_request
      return @header + @alternatives + @classes_profiles + @concordance + @discordance + @method_pararmeters
  end

  def greeting
    "Hello #{@header}"
  end
end
