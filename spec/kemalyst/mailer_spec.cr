require "./spec_helper"

describe Kemalyst::Mailer do
  it "loads settings from mailer.yml" do
    mailer = Kemalyst::Mailer.new
    mailer.settings["host"].to_s.should eq "localhost"
  end

  it "sets the from for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.from "test@test.com"
    mailer.message.from.not_nil!.email.should eq "test@test.com"
  end

  it "sets the to for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.to "test@test.com"
    mailer.message.to.first.not_nil!.email.should eq "test@test.com"
  end

  it "sets the subject for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.subject "subject"
    mailer.message.subject.should eq "subject"
  end

  it "sets the subject for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.body "body"
    mailer.message.body.should eq "body"
  end
end
