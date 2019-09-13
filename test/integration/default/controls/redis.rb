control 'redis-installation' do
  title 'Redis'
  desc 'This test assures that redis is actually installed and running.'
  tag 'redis'
  impact 1.0

  describe service('redis') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe processes('redis-server') do
    it { should exist }
  end

  describe port(6379) do
    it { should be_listening }
    its('processes') { should include 'redis-server' }
    its('protocols') { should include 'tcp' }
    its('addresses') { should_not be_empty }
  end
end

control 'redis-security' do
  title 'Redis (security)'
  desc '
    This test assures that redis was setup according to the security standards at https://redis.io/topics/security
  '
  tag 'redis'
  impact 1.0

  describe port(6379) do
    its('addresses') { should eq ['127.0.0.1'] }
  end

  describe file('/etc/redis.conf') do
    its('content') { should match(/^[^#]*bind\s+127\.0\.0\.1/i) }
  end

  describe processes('redis-server') do
    its('users') { should_not include 'root' }
  end
end
