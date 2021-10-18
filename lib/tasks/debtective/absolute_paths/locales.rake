# frozen_string_literal: true

require "optparse"
require "debtective/absolute_paths/correcter/locales"

namespace :debtective do
  namespace :absolute_paths do
    desc "Find locales absolute paths"
    task :locales do
      options = { verbose: true }
      OptionParser.new do |opts|
        opts.banner = "Usage: rake debtective:absolute_paths:locales [options]"
        opts.on("-a", "--[no-]autocorrect", "Run with autocorrection") do
          options[:autocorrect] = true
        end
      end.parse!

      Debtective::AbsolutePaths::Correcter::Locales.new(**options).call
    end
  end
end
