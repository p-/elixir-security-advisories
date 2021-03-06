require_relative "./elixir_version"

module Elixir
  class Requirement < Gem::Requirement
    OPS = OPS.merge("==" => ->(v, r) { v == r })

    # Override the version pattern to allow local versions
    quoted = OPS.keys.map { |k| Regexp.quote k }.join "|"
    PATTERN_RAW =
      "\\s*(#{quoted})?\\s*(#{Elixir::Version::VERSION_PATTERN})\\s*"
    PATTERN = /\A#{PATTERN_RAW}\z/

    # Override the parser to create Elixir::Versions
    def self.parse obj
      return ["=", obj] if Gem::Version === obj

      unless PATTERN =~ obj.to_s
        raise BadRequirementError, "Illformed requirement [#{obj.inspect}]"
      end

      if $1 == ">=" && $2 == "0"
        DefaultRequirement
      else
        [$1 || "=", Elixir::Version.new($2)]
      end
    end

    def satisfied_by?(version)
      version = Elixir::Version.new(version.to_s)
      requirements.all? { |op, rv| (OPS[op] || OPS["="]).call(version, rv) }
    end
  end
end
