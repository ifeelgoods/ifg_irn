module IfgIrn
  class IrnError < StandardError; end

  class IrnMalformedError < IrnError; end
  class IrnCannotBind < IrnError; end
  class IrnInvalidError < IrnError; end
end
