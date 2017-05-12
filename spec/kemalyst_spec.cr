require "./spec_helper"

describe Kemalyst::Application do
  context "default settings" do
    it "sets the host to 0.0.0.0" do
      app = Kemalyst::Application.instance
      expect(app.host).to eq "0.0.0.0"
    end

    it "sets the port to 3000" do
      app = Kemalyst::Application.instance
      expect(app.port).to eq 3000
    end

    it "sets the env to development" do
      app = Kemalyst::Application.instance
      expect(app.env).to eq "development"
    end

    it "sets the default handlers" do
      app = Kemalyst::Application.instance
      app.setup_handlers
      expect(app.handlers.size).to eq 8
    end
  end

  context "override settings" do
    it "Kemalyst::Application.config will override a setting" do
      app = Kemalyst::Application.instance
      Kemalyst::Application.config do |config|
        config.host = "127.0.0.1"
      end
      expect(app.host).to eq "127.0.0.1"
    end

    it "app.config will override a setting" do
      app = Kemalyst::Application.instance
      app.config do |config|
        config.port = 8080
      end
      expect(app.port).to eq 8080
    end
  end
end
