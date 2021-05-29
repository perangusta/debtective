# frozen_string_literal: true

require "debtective/unused/base"

module Debtective
  module Unused
    # Inspect constants usage
    class Constants < Base
      DEF_DIRECTORIES = %w[app/helpers].freeze
      USE_DIRECTORIES = %w[app/helpers app/controllers app/views].freeze

      DEF_REGEX  = /(?<def>[A-Z](?:[A-Z]|\d|_)+)(?:\s=)/.freeze
      USE_REGEX  = ->(element) { /(?!\w)*#{element}(?!\w|\s=)/ }
    end
  end
end
