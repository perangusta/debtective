# frozen_string_literal: true

require "debtective/unused/base"

module Debtective
  module Unused
    class Helpers < Base
      DEF_DIRECTORIES = %w[app/helpers].freeze
      USE_DIRECTORIES = %w[app/helpers app/controllers app/views].freeze

      DEF_REGEX  = /(?:^|\s)def\s(?<definition>(?:\w+)(?:\?|!)?)(?:\(.*\))?(?:;\send)?(?:\s|$)/.freeze
      USE_REGEX  = ->(element) { /(?<!def\s|\w)#{element}(?!\w)/ }
    end
  end
end
