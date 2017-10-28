# # encoding: utf-8

# Inspec test for recipe tor::administration

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
admin_users = attribute('admin_users', default: [], description: 'Default set of admins')
public_key = attribute('public_key', default: '', description: 'Dummy public key')

control 'sysadmin-access' do
  title 'Administrative Users'
  desc '
    SysAdmins have sufficient access to do the needful
  '

  admin_users.each do |username|
    describe user(username) do
      it { should exist }
      its('groups') { should include 'sudo' }
    end

    describe file("/home/#{username}/.ssh/authorized_keys") do
      it { should exist }
      it { should be_owned_by username }
      it { should be_readable }
      it { should be_writable }
      it { should_not be_executable }
      its('content') { should include public_key }
    end
  end
end
