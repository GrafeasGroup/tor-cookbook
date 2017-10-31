# encoding: utf-8

# Inspec test for recipe tor::app
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'tor-installed' do
  title ''
  desc '
  '

  describe file('/opt/virtualenv/bin/tor-archivist') do
    it { should exist }
    it { should be_executable }
  end

  describe file('/opt/virtualenv/bin/tor-ocr'), :skip do
    it { should exist }
    it { should be_executable }
  end

  describe file('/opt/virtualenv/bin/tor-moderator') do
    it { should exist }
    it { should be_executable }
  end
end
