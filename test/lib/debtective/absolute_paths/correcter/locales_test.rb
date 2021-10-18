# frozen_string_literal: true

require "fileutils"
require "test_helper"
require "debtective/absolute_paths/correcter/locales"

module Debtective
  module AbsolutePaths
    module Correcter
      class LocalesTest < Minitest::Test
        def test_call
          service = Debtective::AbsolutePaths::Correcter::Locales.new
          service.call
          paths = service.path_finders.map { |finder| [finder.locale, finder.path_type, finder.absolute_path] }
          assert_includes paths, ["absolute.path", "absolute", "absolute.path"]
          assert_includes paths, [".relative_path", "relative", "tasks.index.relative_path"]
          assert_includes paths, [".relative.path", "relative", "tasks.index.relative.path"]
          assert_includes paths, ["missing.path", "missing", nil]
          assert_includes paths, ["key.\#{42 + 1}.inter\#{pola}tion", "interpolated", nil]
        end

        def test_call_with_verbose
          service = Debtective::AbsolutePaths::Correcter::Locales.new(verbose: true)

          assert_output(/elements found:\s+6/) { service.call }
          assert_output(/with absolute path:\s+1 \(16\.667%\)/) { service.call }
          assert_output(/with correctable path:\s+2 \(33\.333%\)/) { service.call }
          assert_output(/with uncorrectable path:\s+3 \(50\.0%\)/) { service.call }

          assert_output(/some paths seem to be incorrect. You should check them:/) { service.call }
          assert_output(%r{- path "missing.path" in app/views/tasks/index\.html\.erb}) { service.call }
        end

        def test_call_with_autocorrect
          content_before = File.readlines("#{Rails.root}/app/views/tasks/index.html.erb")
          begin
            service = Debtective::AbsolutePaths::Correcter::Locales.new(autocorrect: true)
            service.call
            content_after = File.readlines("#{Rails.root}/app/views/tasks/index.html.erb")
            assert(content_after.any? { |line| line.include? "tasks.index.relative_path" })
          ensure
            File.write("#{Rails.root}/app/views/tasks/index.html.erb", content_before.join)
          end
        end
      end
    end
  end
end
