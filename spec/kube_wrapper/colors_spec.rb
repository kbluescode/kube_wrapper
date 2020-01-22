# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe KubeWrapper::Colors do
  let(:io_in) { File.open('testinput', 'w+') }
  let(:io_out) { File.open('testoutput', 'w+') }
  let(:runner) { KubeWrapper::Runner.new(io_in, io_out) }

  describe '#print_cyan' do
    it 'should print text with \e[36m prepended' do
      runner.print_cyan('hi')
      io_out.rewind
      output = io_out.read
      expect(output).to start_with(described_class::COLORS[:cyan])
    end
  end

  describe '#print_red' do
    it 'prints text with \e[31m prepended' do
      runner.print_red('hi')
      io_out.rewind
      output = io_out.read
      expect(output).to start_with(described_class::COLORS[:red])
    end
  end

  describe '#print_yellow' do
    it 'prints text with \e[33m prepended' do
      runner.print_yellow('hi')
      io_out.rewind
      output = io_out.read
      expect(output).to start_with(described_class::COLORS[:yellow])
    end
  end

  after(:all) do
    %w[testinput testoutput].each do |file|
      File.delete(file) if File.exist?(file)
    end
  end
end
# rubocop:enable Metrics/BlockLength
