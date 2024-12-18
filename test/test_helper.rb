$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "tindie_api"

require "minitest/autorun"

require 'dotenv'
Dotenv.load