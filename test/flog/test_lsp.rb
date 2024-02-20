# typed: false
# frozen_string_literal: true

require "test_helper"
require "flog_lsp/lsp"

module FlogLsp
  class TestLsp < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil(::FlogLsp::VERSION)
    end

    def test_get_diagnostics
      lsp = ::FlogLsp::Server.new
      diags = lsp.get_diagnostics(<<~RUBY)
        class Foo
          def foo
            if eval("1+2 == 3")
              send(self, :bar)
            else
              send(self, :baz)
            end
          end
        end
      RUBY

      assert_equal(["Foo#foo", "2"], diags[0][0..1])
      assert(diags[0][2] > 10)
    end
  end
end
