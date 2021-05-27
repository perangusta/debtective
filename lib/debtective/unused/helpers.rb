# frozen_string_literal: true

require "debtective/unused/base"

module Debtective
  module Unused
    class Helpers < Base
      DEF_DIRECTORIES = %w[app/helpers].freeze
      DEF_EXTENSIONS  = %w[rb].freeze
      USE_DIRECTORIES = %w[app/helpers app/controllers app/views].freeze
      USE_EXTENSIONS  = %w[rb js erb].freeze

      DEF_BEFORE = /(^|\s)def\s/.freeze
      DEF_HELPER = /(\w+)(\?|!)?/.freeze
      DEF_AFTER  = /(\(.*\))?(;\send)?(\s|$)/.freeze
      DEF_REGEX  = /#{DEF_BEFORE}(?<definition>#{DEF_HELPER})#{DEF_AFTER}/.freeze

      USE_BEFORE = /(?<!def\s|\w)/.freeze
      USE_AFTER  = /(?!\w)/.freeze
      USE_REGEX = ->(element) { /#{USE_BEFORE}#{element}#{USE_AFTER}/ }
    end
  end
end
