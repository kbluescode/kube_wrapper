# frozen_string_literal: true

module KubeWrapper
  # Colors handles printing colored text to output
  module Colors
    COLORS = {
      red: "\e[31m",
      cyan: "\e[36m"
    }.freeze

    def print_cyan(text)
      print_color(text, COLORS[:cyan])
    end

    def print_red(text)
      print_color(text, COLORS[:red])
    end

    def print_color(text, color)
      @io_out.print "#{color}#{text}\e[0m"
    end
  end
end
