# frozen_string_literal: true
default['tor'].tap do |attr|
  attr['tor_revision'] = 'CLOUD-DEPLOYMENT-TEST'
  attr['archivist_revision'] = 'CLOUD-DEPLOYMENT-TEST'
  attr['ocr_revision'] = 'CLOUD-DEPLOYMENT-TEST'
  attr['core_revision'] = 'master'

  attr['backup_ip'] = nil
  attr['backup_ssh_port'] = 22
end
