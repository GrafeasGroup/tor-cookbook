# frozen_string_literal: true
# encoding: utf-8

# Inspec test for recipe tor::python

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'tor-python' do
  title 'Modern python application dependencies'
  desc '
    Dependencies required for a modern python application are
    installed and configured globally
  '

  %w(python36u python36u-pip python36u-devel).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe command('python3.6 --version') do
    its('stdout') { should include '3.6' }
    its('stderr') { should eq '' }
  end

  describe command('python3 --version') do
    its('stdout') { should include '3.4' }
    its('stderr') { should eq '' }
  end

  describe command('virtualenv --help') do
    its('exit_status') { should eq 0 }
  end
end
