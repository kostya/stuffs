require "./spec_helper"

describe "Stuffs" do
  it "URI.escape_uri_safe" do
    URI.escape_uri_safe("/bla-жж/").should eq "/bla-%D0%B6%D0%B6/"
  end
end
