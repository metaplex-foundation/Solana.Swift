Pod::Spec.new do |s|
  s.name             = 'Solana.Swift'
  s.version          = '1.1'
  s.summary          = 'This is a open source library on pure swift for Solana protocol.'


  s.description      = <<-DESC
 This is a open source library on pure swift for Solana protocol.
                       DESC

  s.homepage         = 'https://github.com/ajamaica/Solana.Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ajamaica' => 'arturo.jamaicagarcia@asurion.com' }
  s.source           = { :git => 'https://github.com/ajamaica/Solana.Swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = "10.12"
  s.source_files = 'Sources/Solana/**/*'
  s.swift_versions   = ["5.3"]

  s.dependency 'TweetNacl', '~> 1.0.2'
  s.dependency 'Starscream', '~> 4.0.0'
  s.dependency 'secp256k1.swift'
end
