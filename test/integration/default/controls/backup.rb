# frozen_string_literal: true
# vim: syn=inspec

control 'tor-backups' do
  title 'Disaster recovery'
  impact 0.3

  describe directory('/root/bin') do
    it { should exist }
  end

  describe file('/root/bin/backup-redis') do
    it { should exist }
    it { should be_executable.by_user('root') }
  end

  describe systemd_service('backup_tor_data') do
    it { should be_installed }
    it { should be_enabled }
    it { should_not be_running }
  end
end
