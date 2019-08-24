control 'modern-python' do
  title 'Modern python application dependencies'
  desc '
    Dependencies required for a modern python application are
    installed and configured globally
  '

  %w(python python3 python3.7).each do |python|
    describe python do
      it 'should be installed to /usr/local/bin' do
        cmd = command("test -x '/usr/local/bin/#{python}'")
        expect(cmd.exit_status).to eq 0
      end

      it 'should display 3.7 when passed --version' do
        cmd = command("/usr/local/bin/#{python} --version")
        expect(cmd.exit_status).to eq 0
        expect(cmd.stdout).to include '3.7'
      end

      it 'should have the pip module installed' do
        cmd = command("/usr/local/bin/#{python} -m pip --version")
        expect(cmd.exit_status).to eq 0
      end
    end
  end
end
