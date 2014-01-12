require 'spec_helper'

describe PilotBasic do
  it "creates a new PilotBasic record" do
    record = PilotBasic.create
    expect(record).to be_persisted
  end

  context "scopes" do
    describe "missing_airmen" do
      let(:unique_number) { "A12345" }

      before do
        PilotBasic.create(:unique_number => unique_number)
      end

      it "does not find existing airman by unique_number" do
        Airman.create(:unique_number => unique_number)
        PilotBasic.missing_airmen.should be_empty
      end

      it "finds missing airman by unique_number" do
        missing = PilotBasic.missing_airmen
        expect(missing).to have(1).record
      end
    end
  end
end
