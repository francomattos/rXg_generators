# Expands rXg_API.rg
# Contains the methods for creating scaffold objects under Network menu
class RxgAPI
  # Creates switches, switchport creation via API is not currently supported
  def create_switch(switch_count)
    type = 'SwitchDevice' # Needs to specify to infrastructure what type of device to use
    scaffold = 'switch_devices'
    switch_id = api_get_body(scaffold).size
    payload = []

    switch_count.times do
      switch_id += 1
      switch_pool_index = rand(SWITCH_POOL.size)
      payload.push(
        name: "[#{switch_id}] #{SWITCH_POOL.dig(switch_pool_index, :name)}", # Prepends ID so names are unique
        type: type,
        host: "192.168.10.#{switch_id}", # IP must be unique
        device: SWITCH_POOL.dig(switch_pool_index, :device),
        protocol: 'ssh_coa',
        username: 'admin'
      )
    end

    api_post(payload, scaffold)
  end

  def create_wlan_controller(controller_count)
    type = 'WlanDevice' # Needs to specify to infrastructure what type of device to use
    scaffold = 'wlan_devices'
    controller_id = api_get_body(scaffold).size
    payload = []
    
    controller_count.times do
      controller_id += 1
      controller_pool_index = rand(CONTROLLER_POOL.size)
      payload.push(
        name: "[#{controller_id}] #{CONTROLLER_POOL.dig(controller_pool_index, :name)}", # Prepends ID so names are unique
        type: type,
        host: '192.168.20.' + controller_id.to_s,
        device: CONTROLLER_POOL.dig(controller_pool_index, :device),
        protocol: 'ssh_coa',
        username: 'admin'
      )
    end

    api_post(payload, scaffold)
  end

  # Creates wlan for last created controllers
  def create_wlan(wlan_count)
    controller_array = api_get_body('wlan_devices').last(wlan_count)
    scaffold = 'wlans'
    payload = []

    controller_array.each do |controller_object|
      controller_id = controller_object['id'] # SSID must be tied into the ID of the controller
      ssid_name = SSID_POOL[rand(SSID_POOL.size)]

      payload.push(
        name: ssid_name,
        ssid: ssid_name,
        infrastructure_device: controller_id,
        encryption: 'none',
        authentication: 'none'
      )
    end

    api_post(payload, scaffold)
  end

  def create_access_point(wlan_count)
    # Creates access points for last created controllers
    controller_array = api_get_body('wlan_devices').last(wlan_count)
    scaffold = 'access_points'
    payload = []

    controller_array.each do |controller_object|
      controller_id = controller_object['id']
      # Finds the name of the controller, removing the [number] at beginning
      controller_name = controller_object['name'].split(' ')[1..-1].join(' ')
      controller = CONTROLLER_POOL.find { |c| c[:name] == controller_name }

      # AP count is based on number defined on controller pool, not the count passed by user input
      controller[:apcount].times do
        ap_mac_end = HEXADECIMAL_CHARSET.shuffle!.join[0...6] # Random values to append to mac address

        payload.push(
          infrastructure_device: controller_id,
          name: controller[:apname],
          mac: controller[:apmac] + ap_mac_end # Mac address must be unique
        )
      end
    end

    api_post(payload, scaffold)
  end
end
