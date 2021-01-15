# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'webpacker'

class Webpacker::Remote < Webpacker::Instance
  require 'webpacker/remote/manifest'
  require 'webpacker/remote/configuration'
  require 'webpacker/remote/helper'

  VERSION = '0.1.0'

  class Error < StandardError; end

  attr_reader :public_manifest_content

  # fetch early, fail fast
  # rubocop:disable Lint/MissingSuper
  def initialize(uri:, root_path: nil, config_path: nil) # rubocop:disable Lint/UnusedMethodArgument
    @public_manifest_content = JSON.parse(self.class.get_http_response(uri))
    # deliberately not calling `super` just emulating what's done there
    @root_path = @config_path = Pathname.new('/non-existing-path-for-ctor-compatibility')
  rescue StandardError => e
    raise Error, "#{e.class}: #{e.message}"
  end
  # rubocop:enable Lint/MissingSuper

  def manifest
    @manifest ||= Webpacker::Remote::Manifest.new(self)
  end

  def config
    @config ||= Webpacker::Remote::Configuration.new(
      root_path: root_path,
      config_path: config_path,
      env: env
    )
  end

  # right now this only supports builds done ahead of time
  def env
    'production'
  end

  def self.get_http_response(uri)
    Net::HTTP.get_response(URI.parse(uri)).body
  end
end
