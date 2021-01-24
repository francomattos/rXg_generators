require 'excon'
require 'json'
require_relative "methods.rb"

# rXg production environments should ALWAYS have a valid ssl certificate
# If no valid ssl certificate for device for testing purposes, uncomment line below
Excon.defaults[:ssl_verify_peer] = false

DEVICE_ADDRESS = ""
if DEVICE_ADDRESS.empty?
  puts "Enter device address:"
  DEVICE_ADDRESS = STDIN.gets.chomp!
end

API_KEY = ""
if API_KEY.empty?
  puts "Enter device address:"
  API_KEY = STDIN.gets.chomp!
end

# Checks if no arguments passed, then runs default config
if ARGV.empty?
  puts "predefined config."
  exit!

# Validates that every device has a number of instances to create
elsif ARGV.length.odd?
  puts "Valid Format: Device count."
  puts "You may create as many devices as you wish in one line."
  exit
end

# instantiating  the API class
devapi = Rxg_API.new(DEVICE_ADDRESS,API_KEY)

# Stores created devices
generated_devices = []
# Check if device is valid option and creates device
ARGV.each_index do |i|
  # If it is a number, skip 
  next if ARGV[i].to_i != 0
  # If next device is not a number or negative number, skip
  next if ARGV[i + 1].to_i <= 0

  case ARGV[i].downcase
  when "switch"
    #devapi.create_switch(ARGV[i + 1].to_i)
  when "account"
    #puts "account"
  else
    puts "Automatic generation for #{ARGV[i]} is not yet supported."
    next
  end
  generated_devices.push({:name => ARGV[i], :count =>  ARGV[i+1]})
end

generated_devices.each_index do |i|
  puts "Created #{generated_devices[i][:name]} count: #{generated_devices[i][:count]}"
end
