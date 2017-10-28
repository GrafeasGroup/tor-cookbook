# # encoding: utf-8

# Inspec test for recipe tor::administration

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
admin_users = attribute('admin_users', default: [], description: 'Default set of admins')

admin_users.each do |username|
  describe user(username) do
    it { should exist }
    its('shell') { should include 'bash' }
    its('groups') { should include 'sudo' }
  end
end
