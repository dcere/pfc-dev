#!/usr/bin/env ruby

require 'puppet'
resource = Puppet::Type.type(:torque).new :name => "testing-cloud-torque"
provider = resource.provider

# Might be false (if parameters are not ok) but should not raise anything
provider.exists?

# This should give you a known class
provider.class
