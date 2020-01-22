# frozen_string_literal: true

module KubeWrapper
  # Colors handles printing colored text to output
  module Colors
    COLORS = {
      cyan: "\e[36m",
      red: "\e[31m",
      yellow: "\e[33m"
    }.freeze

    def print_cyan(text)
      print_color(text, COLORS[:cyan])
    end

    def print_red(text)
      print_color(text, COLORS[:red])
    end

    def print_yellow(text)
      print_color(text, COLORS[:yellow])
    end

    private

    def print_color(text, color)
      @io_out.print "#{color}#{text}\e[0m"
    end
  end
end
