module Inquisitive

  module Utils

  private

    def predicate_method?(string)
      string[-1] == '?'
    end

    def predication(string)
      string[0..-2]
    end

  end

end
