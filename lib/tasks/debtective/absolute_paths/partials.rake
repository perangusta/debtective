# frozen_string_literal: true

require "optparse"
require "debtective/absolute_paths/correcter/partials"

namespace :debtective do
  namespace :absolute_paths do
    desc "Find partials absolute paths"
    task :partials do
      options = { verbose: true }
      OptionParser.new do |opts|
        opts.banner = "Usage: rake debtective:absolute_paths:partials [options]"
        opts.on("-a", "--[no-]autocorrect", "Run with autocorrection") do
          options[:autocorrect] = true
        end
      end.parse!

      Debtective::AbsolutePaths::Correcter::Partials.new(**options).call
    end
  end
end
