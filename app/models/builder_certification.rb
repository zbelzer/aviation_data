class BuilderCertification < ActiveRecord::Base
  CODE_MAP = {
    '0' => "Type Certificated",
    '1' => "Not Type Certificated",
    '2' => "Light Sport",
  }
  acts_as_enumerated
end
