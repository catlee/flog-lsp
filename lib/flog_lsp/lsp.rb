# typed: strict
# frozen_string_literal: true

require "language_server-protocol"
require "cgi"
require "uri"
require "flog"
require_relative "version"

# Alias for LanguageServer::Protocol
LSP = LanguageServer::Protocol

module FlogLsp
  class Error < StandardError; end

  class << self
    def logger
      @logger ||= Logger.new($stderr)
    end

    attr_writer :logger
  end

  class Server
    HANDLERS = {
      "initialize" => :handle_initialize,
      "initialized" => :handle_initialized,
      "textDocument/diagnostic" => :handle_diagnostic,
      "textDocument/didOpen" => :handle_open,
      "textDocument/didChange" => :handle_change,
      "textDocument/didClose" => :handle_close,
      "shutdown" => :handle_shutdown,
      "exit" => :handle_exit,
    }

    def initialize
      @file_data = {}
      @options = {}
    end

    def score_threshold
      @options.fetch(:score_threshold, 10)
    end

    def file_data(uri)
      @file_data[uri] ||= begin
        path = CGI.unescape(URI.parse(uri).path)
        logger.debug("Loading file #{path}")
        File.read(path)
      end
    end

    def logger
      FlogLsp.logger
    end

    def start
      writer = LSP::Transport::Stdio::Writer.new
      reader = LSP::Transport::Stdio::Reader.new
      reader.read do |request|
        response = handle(request)
        unless response.nil?
          writer.write(id: request[:id], result: response)
        end
      end
    end

    def handle(request)
      logger.debug("Received request: #{request[:method]}")
      if HANDLERS.key?(request[:method])
        send(HANDLERS[request[:method]], request)
      else
        logger.warn("Unknown request: #{request[:method]}")
        nil
      end
    end

    def handle_initialize(request)
      logger.debug("Initializing with request: #{request}")
      @options = request[:params][:initializationOptions] || {}

      LSP::Interface::InitializeResult.new(
        capabilities: LSP::Interface::ServerCapabilities.new(
          text_document_sync: LSP::Interface::TextDocumentSyncOptions.new(
            change: LSP::Constant::TextDocumentSyncKind::INCREMENTAL,
            open_close: true,
          ),
          diagnostic_provider: LSP::Interface::DiagnosticOptions.new(
            identifier: "flog",
            inter_file_dependencies: false,
            workspace_diagnostics: false,
          ),
        ),
        server_info: {
          name: "Flog LSP",
          version: FlogLsp::VERSION,
        },
      )
    end

    def handle_initialized(request)
      nil
    end

    def handle_shutdown(request)
      nil
    end

    def handle_exit(request)
      Kernel.exit(0)
    end

    def handle_open(request)
      # Load the file
      uri = request[:params][:textDocument][:uri]
      file_data(uri)
      nil
    end

    def handle_close(request)
      uri = request[:params][:textDocument][:uri]
      @file_data.delete(uri)
      nil
    end

    def get_prefix(lines, line, character)
      lines[0...line].join + lines[line][0...character]
    end

    def get_suffix(lines, line, character)
      if line >= lines.length
        ""
      else
        lines[line][character..] + lines[line + 1..].join
      end
    end

    def patch_contents(contents, range, text)
      lines = contents.lines
      prefix = get_prefix(lines, range[:start][:line], range[:start][:character])
      suffix = get_suffix(lines, range[:end][:line], range[:end][:character])
      prefix + text + suffix
    end

    def handle_change(request)
      uri = request[:params][:textDocument][:uri]
      request[:params][:contentChanges].each do |change|
        @file_data[uri] = if change.key?(:range)
          patch_contents(file_data(uri), change[:range], change[:text])
        else
          change[:text]
        end
      end
      nil
    end

    def get_diagnostics(contents)
      flog = Flog.new
      flog.flog_ruby(contents)
      flog.calculate_total_scores
      flog.totals.filter_map do |method_name, score|
        next if score <= score_threshold

        location = flog.method_locations[method_name]
        next unless location

        _filename, range = location.split(":")
        start_line, _end_line = range.split("-")
        [method_name, start_line, score]
      end
    end

    def handle_diagnostic(request)
      uri = request[:params][:textDocument][:uri]
      contents = file_data(uri)
      diagnostics = get_diagnostics(contents).map do |method_name, start_line, score|
        LSP::Interface::Diagnostic.new(
          range: LSP::Interface::Range.new(
            start: LSP::Interface::Position.new(line: start_line.to_i - 1, character: 0),
            end: LSP::Interface::Position.new(line: start_line.to_i - 1, character: 0),
          ),
          severity: LSP::Constant::DiagnosticSeverity::WARNING,
          source: "flog",
          message: "#{method_name} has a flog score of #{score.round(2)}",
          data: { correctable: false },
        )
      end
      LSP::Interface::FullDocumentDiagnosticReport.new(kind: "full", items: diagnostics)
    rescue StandardError => e
      logger.error("Error calculating flog: #{e}")
      LSP::Interface::FullDocumentDiagnosticReport.new(kind: "full", items: [])
    end
  end
end
