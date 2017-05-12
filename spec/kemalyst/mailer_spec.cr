require "./spec_helper"

describe Kemalyst::Mailer do
  it "loads settings from mailer.yml" do
    mailer = Kemalyst::Mailer.new
    expect(mailer.settings["url"].to_s).to eq "localhost:25"
  end

  it "sets the from for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.from "test@test.com"
    expect(mailer.message.from.not_nil!.email).to eq "test@test.com"
  end

  it "sets the to for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.to "test@test.com"
    expect(mailer.message.to.first.not_nil!.email).to eq "test@test.com"
  end

  it "sets the cc for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.cc "test@test.com"
    expect(mailer.message.cc.first.not_nil!.email).to eq "test@test.com"
  end

  it "sets the bcc for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.bcc "test@test.com"
    expect(mailer.message.bcc.first.not_nil!.email).to eq "test@test.com"
  end

  it "sets the subject for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.subject "subject"
    expect(mailer.message.subject).to eq "subject"
  end

  it "sets the subject for the message" do
    mailer = Kemalyst::Mailer.new
    mailer.body "body"
    expect(mailer.message.body).to eq "body"
  end
end
