# encoding: utf-8

# Inspec test for recipe tor::app
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'tor-installed' do
  title 'ToR Bot installation'

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

control 'tor-configured' do
  title 'ToR Bot configuration'

  describe file('/var/tor/praw.ini') do
    it { should exist }
    its('content') { should include '[example]', 'client_id=a', 'client_secret=b', 'username=example_user', 'password=S' }
  end
end
