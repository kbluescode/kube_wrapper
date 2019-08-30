RSpec.describe KubeWrapper do
  it 'has a version number' do
    expect(KubeWrapper::VERSION).not_to be nil
  end

  describe '::run' do
    subject { described_class.run }

    let(:fd) { IO.sysopen('testinput', 'w+') }
    let(:io_in) { IO.new(fd, 'w+') }
    let(:fd2) { IO.sysopen('testoutput', 'w+') }
    let(:io_out) { IO.new(fd2, 'w+') }
    let(:runner) { KubeWrapper::Runner.new(io_in, io_out) }

    before do
      allow_any_instance_of(KubeWrapper::Runner).to receive(:on)
      allow_any_instance_of(KubeWrapper::Runner).to receive(:start!)
    end

    it 'creates a new Runner' do
      expect(KubeWrapper::Runner).to receive(:new).and_return(runner)
      subject
    end

    after do
      %w[testinput testoutput].each do |file|
        File.delete(file) if File.exist?(file)
      end
    end
  end
end
