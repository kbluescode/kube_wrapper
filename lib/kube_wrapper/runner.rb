# frozen_string_literal: true

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
          Changes namespace prefix for further commands to $1. \
          Pass nothing to print all available namespaces
        DESC
      },
      clear: {
        cmds: %w[cl clear],
        blurb: 'Clears the screen'
      },
      set_context: {
        cmds: ['set-c', '-c'],
        blurb: <<~DESC
          Changes kubernetes context. \
          Pass nothing to print all available contexts
        DESC
      }
    }.freeze

    attr_reader :context, :namespace

    def initialize(io_in = STDIN, io_out = STDOUT)
      @io_in = io_in
      @io_out = io_out
      @namespace = 'default'
      @context = `kubectl config current-context`.chomp
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

    def fetch_input
      @io_in.gets.chomp.split(' ')
    rescue NoMethodError, Interrupt
      exit!
    end

    def update_context!(context)
      if context.nil? || context.empty?
        puts `kubectl config get-contexts`
        return
      end

      context = Shellwords.escape(context)
      result = `kubectl config use-context #{context}`
      return if result.empty?

      @io_out.puts "Context set to #{context}"
      @context = context
    end

    def update_namespace!(namespace)
      if namespace.nil? || namespace.empty?
        puts `kubectl get ns`
        return
      end

      @namespace = namespace
      @io_out.puts "Namespace set to #{@namespace}"
    end

    def handle_input(input) # rubocop:disable Metrics/AbcSize
      case input.first
      when *COMMANDS[:help][:cmds] then print_help
      when *COMMANDS[:set_namespace][:cmds] then update_namespace!(input[1])
      when *COMMANDS[:clear][:cmds] then @io_out.print "\e[2J\e[f"
      when *COMMANDS[:set_context][:cmds] then update_context!(input[1])
      else
        @io_out.puts `kubectl -n #{namespace} #{Shellwords.shelljoin(input)}`
      end
    end

    def run
      print_yellow "(#{context}) "
      print_cyan "kubectl -n #{namespace} "
      input = fetch_input
      handle_input(input)
    end
  end
end
