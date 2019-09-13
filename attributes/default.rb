default['tor'].tap do |attr|
  attr['tor_revision'] = 'CLOUD-DEPLOYMENT-TEST'
  attr['archivist_revision'] = 'CLOUD-DEPLOYMENT-TEST'
  attr['ocr_revision'] = 'CLOUD-DEPLOYMENT-TEST'
  attr['core_revision'] = 'master'
  attr['python_version'] = '3.7.4'
end
