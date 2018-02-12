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

  describe file('/opt/virtualenv/bin/tor-apprentice') do
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

  %w[tor_moderator tor_ocr tor_archivist].each do |bot|
    describe file("/var/tor/#{bot}.env") do
      it { should exist }

      its('content') { should match(/^REDIS_CONNECTION_URL=\S+$/) }
      its('content') { should match(/^BUGSNAG_API_KEY=\S+$/) }
      its('content') { should match(/^SLACK_API_KEY=\S+$/) }
      its('content') { should match(/^SENTRY_API_URL=\S+$/) }
      its('content') { should match(/^HEARTBEAT_FILE=\S+$/) }
      its('content') { should match(/^MODCHAT_API_URL=\S+$/) }
      its('content') { should match(/^MODCHAT_API_USERNAME=\S+$/) }
      its('content') { should match(/^MODCHAT_API_PASSWORD=\S+$/) }
    end
  end
end

control 'tor-services' do
  title 'ToR Bots are running'

  describe service('tor_moderator') do
    it { should be_installed }
    it { should be_enabled }
  end

  describe service('tor_ocr') do
    it { should be_installed }
    it { should be_enabled }
  end

  describe service('tor_archivist') do
    it { should be_installed }
    it { should be_enabled }
  end
end
