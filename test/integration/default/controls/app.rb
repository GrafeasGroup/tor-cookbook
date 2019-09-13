control 'tor-moderator' do
  title 'ToR moderator bot'
  desc 'The moderation bot is installed and configured correctly'
  impact 1.0

  describe directory('/var/tor/tor_moderator') do
    it { should exist }
  end

  describe file('/var/tor/tor_moderator/environment') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match(/^REDIS_CONNECTION_URL='\S+'$/) }
    its('content') { should match(/^BUGSNAG_API_KEY='\S+'$/) }
    its('content') { should match(/^SLACK_API_KEY='\S+'$/) }
    its('content') { should match(/^HEARTBEAT_FILE='\S+'$/) }
  end

  describe file('/var/tor/tor_moderator/praw.ini') do
    it { should exist }
    its('content') { should include '[tor]' }
    its('owner') { should eq 'tor_bot' }
    its('group') { should eq 'bots' }
    its('mode') { should cmp '600' }
    # its('content') { should include '[example]', 'client_id=a', 'client_secret=b', 'username=example_user', 'password=S' }
  end

  describe file('/var/tor/tor_moderator/venv/bin/tor-moderator') do
    it { should exist }
    it { should be_executable }
  end

  describe service('tor_moderator') do
    it { should be_installed }
    it { should be_enabled }
  end
end

control 'tor-ocr' do
  title 'ToR OCR bot'
  desc 'The apprentice bot is installed and configured correctly'
  impact 1.0

  describe directory('/var/tor/tor_ocr') do
    it { should exist }
  end

  describe file('/var/tor/tor_ocr/environment') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match(/^REDIS_CONNECTION_URL='\S+'$/) }
    its('content') { should match(/^BUGSNAG_API_KEY='\S+'$/) }
    its('content') { should match(/^SLACK_API_KEY='\S+'$/) }
    its('content') { should match(/^HEARTBEAT_FILE='\S+'$/) }
  end

  describe file('/var/tor/tor_ocr/praw.ini') do
    it { should exist }
    its('content') { should include '[tor_ocr]' }
    its('owner') { should eq 'tor_bot' }
    its('group') { should eq 'bots' }
    its('mode') { should cmp '600' }
    # its('content') { should include '[example]', 'client_id=a', 'client_secret=b', 'username=example_user', 'password=S' }
  end

  describe file('/var/tor/tor_ocr/venv/bin/tor-apprentice') do
    it { should exist }
    it { should be_executable }
  end

  describe service('tor_ocr') do
    it { should be_installed }
    it { should be_enabled }
  end
end

control 'tor-archivist' do
  title 'ToR archivist bot'
  desc 'The historian bot is installed and configured correctly'
  impact 1.0

  describe directory('/var/tor/tor_archivist') do
    it { should exist }
  end

  describe file('/var/tor/tor_archivist/environment') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match(/^REDIS_CONNECTION_URL='\S+'$/) }
    its('content') { should match(/^BUGSNAG_API_KEY='\S+'$/) }
    its('content') { should match(/^SLACK_API_KEY='\S+'$/) }
    its('content') { should match(/^HEARTBEAT_FILE='\S+'$/) }
  end

  describe file('/var/tor/tor_archivist/praw.ini') do
    it { should exist }
    its('content') { should include '[tor_archivist]' }
    its('owner') { should eq 'tor_bot' }
    its('group') { should eq 'bots' }
    its('mode') { should cmp '600' }
    # its('content') { should include '[example]', 'client_id=a', 'client_secret=b', 'username=example_user', 'password=S' }
  end

  describe file('/var/tor/tor_archivist/venv/bin/tor-archivist') do
    it { should exist }
    it { should be_executable }
  end

  describe service('tor_archivist') do
    it { should be_installed }
    it { should be_enabled }
  end
end
