require 'shellwords'

module KubeWrapper
  class Runner
    COLORS = {
      red: "\e[31m".freeze,
      cyan: "\e[36m".freeze,
    }

    attr_reader :namespace

    def initialize(verbose=false)
      @namespace = 'default'
      @verbose = verbose
      @callbacks = {}
    end

    def on(key, &block)
      @callbacks[key] = block
    end

    def exit!
      puts
      @callbacks[:exit].call
      exit
    end

    def start!
      @callbacks[:start].call
      loop { run }
    end

    private

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
      puts "halp"
    end

    def run
      print_cyan "kubectl -n #{namespace} "
      begin
        input = gets.chomp.split(' ')
      rescue NoMethodError, Interrupt
        exit!
      end
      puts "you gave '#{input}'" if @verbose
      case input.first
      when '?','-h','--help'
        print_help
      when 'set-n'
        @namespace = input[1]
      else
        puts `kubectl -n #{namespace} #{input.join(' ')}`
      end
    end
  end
end