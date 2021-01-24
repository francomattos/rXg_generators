# This is the main class for handling rXg api requests from the code
class Rxg_API

  # Receives host address and api keys from main and converts it to format used by class
  def initialize(address, api_key)
    @device_address = address + '/admin/scaffolds/'
    @device_api_key = '?api_key=' + api_key
  end

  # Method to connect to rXg API and deliver payload
  def generate(payload_array, object_type)
    post_url = @device_address + object_type + '/create.json' + @device_api_key

    # Initiates a connection to be used for requests
    api_connection = Excon.new(post_url, :persistent => true)

    # Creates a thread array to keep requests concurrent
    threads = []

    # Cycles through the payload and creates a thread with the post request to API
    payload_array.each do |payload|
      threads << Thread.new { 
      api_connection.post( 
      :body => '{ "record":' + payload.to_json + '}',
      :headers => {'Content-Type' => 'application/json'},
      :persistent => true
      )}
    end
    threads.each(&:join)
  end

  # Method for creating switches, receives number of device to create as argument
  def create_switch(switch_count)
    get_url = @device_address + 'switch_devices/index.json' + @device_api_key
    object_type = "switch_devices"

    # Very important, needs to specify to infrastructure what type of device to use
    type = 'SwitchDevice'

    # Creates a database of switch devices to be created with amount of ports
    switch_names = Array[
        { name: 'Cisco Catalyst 9000', device: 'ciscoios', ports: 16 },
        { name: 'Juniper EX4200', device: 'juniperex', ports: 16 },
        { name: 'Ruckus ICX', device: 'ruckusicx', ports: 16 }
    ]

    # Retreives list of switch devices, and gets the count to set as host and label
    host = JSON.parse(Excon.get(get_url).body).length

    # Creates payload for switch device to be sent via API
    payload = []
    switch_count.times do
      host += 1
      switch_names_index = rand(switch_names.length)
      payload.push({
                     name: "[#{host}] #{switch_names[switch_names_index][:name]}",
                     type: type,
                     host: "192.168.60.#{host.to_s}",
                     device: switch_names[switch_names_index][:device],
                     protocol: 'ssh_coa',
                     username: 'admin'
                   })
    end

    # Sends post request with payload
    self.generate(payload, object_type)

  end
end
