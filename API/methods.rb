class Rxg_API
  def initialize(address, api_key)
    @device_address = address + '/admin/scaffolds/'
    @device_api_key = '?api_key=' + api_key
  end

  def testdevice
    puts @device_address + @device_api_key
  end

  def create_switch(switch_count)
    get_uri = URI @device_address + 'switch_devices/index.json' + @device_api_key
    post_uri = URI @device_address + 'infrastructure_devices/create.json' + @device_api_key
    type = 'SwitchDevice'

    # Creates a database of switch devices to be created with amount of ports
    switch_names = Array[
        { name: 'Cisco Catalyst 9000', device: 'ciscoios', ports: 16 },
        { name: 'Juniper EX4200', device: 'juniperex', ports: 16 },
        { name: 'Ruckus ICX', device: 'ruckusicx', ports: 16 }
    ]

    # Retreives list of switch devices, and gets the device count
    # host = JSON.parse(Net::HTTP.get(get_uri)).length
   
    host = 1

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
                     created_by: 'System Generated',
                     updated_by: 'System Generated',
                     protocol: 'ssh_coa',
                     username: 'admin'
                   })
    end

    https_request = Net::HTTP::Post.new(post_uri.path, initheader = {'Content-Type' =>'application/json'})
    https_request.body = payload.to_json
    https_reponse = Net::HTTP.start(post_uri.hostname, post_uri.port) do 
      |https| 
      https.request(https_request) 
    end
    puts https_reponse.body
  end
end
