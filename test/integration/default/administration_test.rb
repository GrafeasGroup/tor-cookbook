# # encoding: utf-8

# Inspec test for recipe tor::administration

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
admin_users = attribute('admin_users', default: [], description: 'Default set of admins')

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
  end
end
