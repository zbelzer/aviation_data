require 'spec_helper'

describe PilotCert do
  it "creates a new PilotCert record" do
    record = PilotCert.create
    expect(record).to be_persisted
  end

  context "scopes" do
    describe "missing_certifications" do
      let(:unique_number) { "A12345" }
      let(:certificate_type) { CertificateType["P"] }

      before do
        PilotCert.create(:unique_number => unique_number, :certificate_type => certificate_type.name)
      end

      it "finds only certs for airmen who are present in the database" do
        Airman.create(:unique_number => unique_number)
        expect(PilotCert.missing_certifications).to have(1).record
      end

      it "returns returns containing airman_id" do
        Airman.create(:unique_number => unique_number)
        result = PilotCert.missing_certifications.first
        expect(result.airman_id).to_not be_nil
      end

      it "does not find existing certs for airman" do
        airman = Airman.create(:unique_number => unique_number)
        airman.certificates.create(:certificate_type_id => certificate_type.id)

        expect(PilotCert.missing_certifications).to be_empty
      end

      it "finds only new certs for existing airmen" do
        airman = Airman.create(:unique_number => unique_number)
        airman.certificates.create(:certificate_type_id => certificate_type.id)

        PilotCert.create(:unique_number => unique_number, :certificate_type => CertificateType["Y"].name)

        expect(PilotCert.missing_certifications).to have(1).record
      end
    end
  end
end
