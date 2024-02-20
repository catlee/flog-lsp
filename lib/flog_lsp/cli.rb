# typed: false
# frozen_string_literal: true

require "optparse"
require "logger"
require "flog_lsp/lsp"

module FlogLsp
  module Cli
    class << self
      def start
        options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: flog-lsp [options]"
          opts.on("-v", "--verbose", "Run verbosely") do |v|
            options[:verbose] = v
          end
          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
        end.parse!
        logger = FlogLsp.logger = Logger.new($stderr)
        # logger = FlogLsp.logger = Logger.new("flog-lsp.log")
        logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
        logger.info("flog-lsp version #{FlogLsp::VERSION} starting...")
        lsp = FlogLsp::Server.new
        lsp.start
      end
    end
  end
end
