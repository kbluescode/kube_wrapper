require 'shellwords'

module KubeWrapper
  # Runner creates a REPL to run kubectl commands
  class Runner
    COLORS = {
      red: "\e[31m".freeze,
      cyan: "\e[36m".freeze
    }.freeze

    attr_reader :namespace

    def initialize
      @namespace = 'default'
      @callbacks = {}
    end

    def on(key, &block)
      @callbacks[key] = block
    end

    def start!
      @callbacks[:start].call
      loop { run }
    end

    private

    def exit!
      puts
      @callbacks[:exit].call
      exit
    end

    def print_cyan(text)
      print_color(text, COLORS[:cyan])
    end

    def print_red(text)
      print_color(text, COLORS[:red])
    end

    def print_color(text, color)
      print "#{color}#{text}\e[0m"
    end

    def print_help
      puts 'halp'
    end

    def fetch_input
      gets.chomp.split(' ')
    rescue NoMethodError, Interrupt
      exit!
    end

    def handle_input(input)
      case input.first
      when '?', '-h', '--help'
        print_help
      when 'set-n', '-n', '--namespace'
        @namespace = input[1]
      else
        puts `kubectl -n #{namespace} #{input.join(' ')}`
      end
      nil
    end

    def run
      print_cyan "kubectl -n #{namespace} "
      input = fetch_input
      handle_input(input)
    end
  end
end
