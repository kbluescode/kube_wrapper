require 'kube_wrapper/colors'
require 'shellwords'

module KubeWrapper
  # Runner creates a REPL to run kubectl commands
  class Runner
    include KubeWrapper::Colors

    COMMANDS = {
      help: {
        cmds: ['?', '-h', '--help'],
        blurb: 'Prints this help blurb'
      },
      set_namespace: {
        cmds: ['set-n', '-n'],
        blurb: <<~DESC
          Changes namespace prefix for further commands to $1. Defaults to `default`
        DESC
      },
      clear: {
        cmds: %w[cl clear],
        blurb: 'Clears the screen'
      }
    }.freeze

    attr_reader :namespace

    def initialize(io_in = STDIN, io_out = STDOUT)
      @io_in = io_in
      @io_out = io_out
      @namespace = 'default'
      @callbacks = {}
    end

    def on(key, &block)
      @callbacks[key] = block
    end

    def start!
      @callbacks[:start]&.call
      print_help
      loop { run }
    end

    private

    def exit!
      @io_out.puts
      @callbacks[:exit]&.call
      exit
    end

    def print_help
      COMMANDS.each do |_, cmd|
        @io_out.puts "#{cmd[:cmds]}: #{cmd[:blurb]}"
    end
    end

    def print_color(text, color)
      @io_out.print "#{color}#{text}\e[0m"
    end

    def print_help
      @io_out.puts 'halp'
    end

    def fetch_input
      @io_in.gets.chomp.split(' ')
    rescue NoMethodError, Interrupt
      exit!
    end

    def update_namespace!(namespace)
      @namespace = namespace || 'default'
      @io_out.puts "Namespace set to #{@namespace}"
    end

    def handle_input(input)
      case input.first
      when *COMMANDS[:help][:cmds] then print_help
      when *COMMANDS[:set_namespace][:cmds] then update_namespace!(input[1])
      when *COMMANDS[:clear][:cmds] then print "\e[2J\e[f"
      else
        @io_out.puts `kubectl -n #{namespace} #{Shellwords.shelljoin(input)}`
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
