require 'spec_helper'

describe Aircraft do
  it { should belong_to(:model) }
  it { should belong_to(:identifier) }
end
