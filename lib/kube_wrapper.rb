require 'kube_wrapper/version'
require 'kube_wrapper/runner'

# KubeWrapper handles wrapping commands to kubectl to make it easier to use
module KubeWrapper
  class Error < StandardError; end

  class << self
    def run
      runner = Runner.new
      runner.on(:start) { puts "Starting Kubernetes Wrapper" }
      runner.on(:exit) { puts "Exiting Kubernetes Wrapper" }
      runner.start!
    end
  end
end
