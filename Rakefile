# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
require 'bubble-wrap/core'

Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'reactivekittens'
  app.device_family = [:iphone]
  app.info_plist['UIStatusBarStyle'] = 'UIStatusBarStyleBlackTranslucent'
  #app.icons = ["AppIcon.png"]

  app.pods do
    pod 'AFNetworking-RACExtensions'
  end
  app.vendor_project('vendor/ReactiveMotion', :static, cflags: '-I../Pods/ReactiveCocoa/ReactiveCocoaFramework')
  app.vendor_project('vendor/BlockBuilder', :static)

  # app.development do
  #   app.codesign_certificate = 'iPhone Developer: Karlin Fox'
  #   app.provisioning_profile = "my.mobileprovision"
  # end
end
