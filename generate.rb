#
# Created by Franco Mattos
# github.com/francomattos
#
# This tool is used to generate an artificial environment inside the rXg
# See the help menu for more information: generate --help
#

require 'excon'
require 'json'
require_relative 'API/rXg_API'

# Configure a static device address and API key here
# Device address format example: https://google.com
# device_address = ''
# api_key = ''

# rXg production environments should ALWAYS have a valid ssl certificate
# If no valid ssl certificate for device uncomment line below
# Excon.defaults[:ssl_verify_peer] = false

if ['help', '--help', '-h'].include?(ARGV[0])
  puts '
    This program will generate an artificial evironemnt for an rXg device
    You must enter the FQDN and API key each time, or statically configure inside script
    Syntax use: generate object count
    You may enter many objects in a single line
    Using command without any arguments runs default configuration

    Supported objects:
    | switch | wlan |
    '
  exit!
elsif ARGV.length.odd?
  puts 'Invalid format, you must define object and how many to create. type generate --help for help menu.'
  exit!
end

# You may customize a default configuration here
if ARGV.empty?
  puts 'predefined config.'
  exit!
end

# device_address and api_key must be initialized to nil if not statically configured above
rxg_generator = RxgAPI.new(device_address ||= nil, api_key ||= nil)

generated_devices = []

ARGV.each_index do |i|
  next if ARGV[i].to_i != 0 # If value is a number, skip
  next if ARGV[i + 1].to_i <= 0 # If next device is not a number or negative number, skip
  object_name = ARGV[i]
  create_count = ARGV[i + 1].to_i

  case object_name.downcase
  when 'switch'
    #rxg_generator.create_switch(create_count)
  when 'wlan'
    rxg_generator.create_wlan_controller(create_count)
    rxg_generator.create_wlan(create_count)
    rxg_generator.create_access_point(create_count)
  else
    puts "Automatic generation for #{object_name} is not yet supported."
    next
  end

  generated_devices.push({ name: object_name, count: create_count })
end

# Returns confirmation of devices created
generated_devices.each_index do |i|
  puts "Created #{generated_devices[i][:name]} count: #{generated_devices[i][:count]}"
end

