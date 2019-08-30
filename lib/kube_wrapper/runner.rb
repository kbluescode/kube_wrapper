module KubeWrapper
  # Runner creates a REPL to run kubectl commands
  class Runner
    COLORS = {
      red: "\e[31m".freeze,
      cyan: "\e[36m".freeze
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
      cb = @callbacks[:start]
      cb.call if cb
      loop { run }
    end

    private

    def exit!
      @io_out.puts
      cb = @callbacks[:exit]
      cb.call if cb
      exit
    end

    def print_cyan(text)
      print_color(text, COLORS[:cyan])
    end

    def print_red(text)
      print_color(text, COLORS[:red])
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

    def handle_input(input)
      case input.first
      when '?', '-h', '--help'
        print_help
      when 'set-n', '-n', '--namespace'
        @namespace = input[1]
      else
        @io_out.puts `kubectl -n #{namespace} #{input.join(' ')}`
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
