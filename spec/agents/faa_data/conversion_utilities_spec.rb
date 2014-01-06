require 'spec_helper'

describe FaaData::ConversionUtilities do
  def create_tempfile(data)
    file = Tempfile.new("test")
    file.write data
    file.close

    yield file

    file.close
    file.unlink
  end

  def compare_tempfile(file, expected_data)
    file.open
    expect(file.read).to eq(expected_data)
  end

  let(:sample_with_spaces) do
    "A4026773,DAVID \"ACE\" JOSEPH                  ,BELZER                        ,12301 MIRASOL                    ,                                 ,IRVINE           ,CA,92620-0304,USA               ,WP,1,072013,072014,"
  end

  let(:sample) do
    "A4026773,DAVID \"ACE\" JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,072014,"
  end

  describe "prepare_for_import" do
    it "yields a path to an actual file" do
      create_tempfile(sample) do |file|
        FaaData::ConversionUtilities.prepare_for_import(file.path) do |working_file|
          File.exist?(working_file).should be_true
        end
      end
    end
  end

  describe "compress_whitespace" do
    it "removes garbage whitespace" do
      create_tempfile(sample_with_spaces) do |file|
        FaaData::ConversionUtilities.compress_whitespace(file.path)
        compare_tempfile(file, "A4026773,DAVID \"ACE\" JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,072014,")
      end
    end

    it "removes literal carriage returns" do
      sample = "A4026773,DAVID JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,072014\r"

      create_tempfile(sample) do |file|
        FaaData::ConversionUtilities.compress_whitespace(file.path)
        compare_tempfile(file, "A4026773,DAVID JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,072014")
      end
    end
  end

  describe "fix_columns" do
    it "removes *extra* trailing commas" do
      create_tempfile(sample) do |file|
        FaaData::ConversionUtilities.fix_columns(file.path)
        compare_tempfile(file, "A4026773,DAVID \"ACE\" JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,072014")
      end
    end

    it "does not *correct* remove trailing commas" do
      sample = 'A4026773,DAVID JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,,'

      create_tempfile(sample) do |file|
        FaaData::ConversionUtilities.fix_columns(file.path)
        compare_tempfile(file, "A4026773,DAVID JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,,")
      end
    end
  end

  describe "escape_quotes" do
    it "escapes quotes" do
      create_tempfile(sample) do |file|
        FaaData::ConversionUtilities.escape_quotes(file.path)
        compare_tempfile(file, "A4026773,DAVID \"ACE\" JOSEPH,BELZER,12301 MIRASOL,,IRVINE,CA,92620-0304,USA,WP,1,072013,072014,")
      end
    end
  end

  describe "fill_empty_columns" do
    it "replaces blank columns with '\N'" do
      create_tempfile("A0000098,KEVIN PATRICK,MCGRADY,PO BOX 714,,LITCHFIELD,CT,06759-0714,USA,EA,,") do |file|
        FaaData::ConversionUtilities.fill_empty_columns(file.path)
        compare_tempfile(file, 'A0000098,KEVIN PATRICK,MCGRADY,PO BOX 714,\N,LITCHFIELD,CT,06759-0714,USA,EA,\N,\N')
      end
    end
  end

  describe "remove_header" do
    it "removes the first line of input, assuming that it's the header" do
      data = <<EOF
UNIQUE ID, FIRST NAME, LAST NAME, STREET 1, STREET 2, CITY, STATE, ZIP CODE, COUNTRY, REGION, MED CLASS, MED DATE, MED EXP DATE,
#{sample}
EOF
      create_tempfile(data.chomp) do |file|
        FaaData::ConversionUtilities.remove_header(file.path)
        compare_tempfile(file, sample)
      end

    end
  end
end
