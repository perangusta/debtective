# frozen_string_literal: true

require "fileutils"
require "test_helper"
require "debtective/absolute_paths/correcter/partials"

module Debtective
  module AbsolutePaths
    module Correcter
      class PartialsTest < Minitest::Test
        def test_call
          service = Debtective::AbsolutePaths::Correcter::Partials.new
          service.call
          paths = service.path_finders.map { |finder| [finder.partial, finder.path_type, finder.absolute_path] }
          assert_includes paths, ["tasks/relative/path", "absolute", "tasks/relative/path"]
          assert_includes paths, ["relative_path", "relative", "tasks/relative_path"]
          assert_includes paths, ["relative/path", "relative", "tasks/relative/path"]
          assert_includes paths, ["missing", "missing", nil]
          assert_includes paths, ["tasks/\#{42 + 1}/inter\#{pola}tion", "interpolated", nil]
        end

        def test_call_with_verbose
          service = Debtective::AbsolutePaths::Correcter::Partials.new(verbose: true)

          assert_output(/elements found:\s+\d+/) { service.call }
          assert_output(/with absolute path:\s+\d+ \(\d+\.\d+%\)/) { service.call }
          assert_output(/with correctable path:\s+\d+ \(\d+\.\d+%\)/) { service.call }
          assert_output(/with uncorrectable path:\s+\d+ \(\d+\.\d+%\)/) { service.call }

          assert_output(/some paths seem to be incorrect. You should check them:/) { service.call }
          assert_output(%r{- path "missing" in app/views/tasks/index\.html\.erb}) { service.call }
        end

        def test_call_with_autocorrect
          content_before = File.readlines("#{Rails.root}/app/views/tasks/index.html.erb")
          begin
            service = Debtective::AbsolutePaths::Correcter::Partials.new(autocorrect: true)
            service.call
            content_after = File.readlines("#{Rails.root}/app/views/tasks/index.html.erb")
            assert(content_after.any? { |line| line.include? "tasks/relative/path" })
            assert(content_after.any? { |line| line.include? "tasks/relative_path" })
          ensure
            File.write("#{Rails.root}/app/views/tasks/index.html.erb", content_before.join)
          end
        end
      end
    end
  end
end
