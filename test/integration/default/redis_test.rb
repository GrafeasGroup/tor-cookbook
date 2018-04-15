# frozen_string_literal: true
# encoding: utf-8

# Inspec test for recipe tor::redis

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

raise 'Only CentOS is supported' unless os.redhat?

control 'redis-installation' do
  title 'Redis'
  desc '
    This test assures that redis is actually installed and running.
  '
  tag 'redis'

  describe package('redis') do
    it { should be_installed }
  end

  describe systemd_service('redis') do
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
