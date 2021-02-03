# Expands rXg_API.rg
# Contains the methods for creating scaffold objects under Identities menu

class RxgAPI
  # Creating an account will also create 1 account group and several devices tied to accounts
  def create_account(account_count)
    scaffold = 'accounts'
    groups_array = api_get_body('account_groups')
    account_group = nil

    # If there are groups created, use the last one
    if groups_array.length > 0
      account_group = {
        name: groups_array.last['name'],
        id: groups_array.last['id'],
        priority: groups_array.last['priority']
      }  
    end

    payload = []
    account_count.times do 
      first_name = @first_name_pool[rand(@first_name_pool.length)]
      last_name = @last_name_pool[rand(@last_name_pool.length)]
      random_uid = rand(9999).to_s
      login = first_name[0, 1].downcase + last_name.downcase + random_uid # Must be unique, so has to have appended uid
      email = first_name[0, 1].downcase + last_name[0, 1].downcase + random_uid + "@" + @email_domain_pool[rand(@email_domain_pool.length)]
      user_password = @alphanumeric_charset.shuffle!.join[0...10]

      payload.push({
        login: login,
        password: user_password, 
        password_confirmation: user_password,
        email: email,
        first_name: first_name,
        last_name: last_name,
        account_group: account_group,
        phone: sprintf('%i%i%i', rand(200...700), rand(100...999), rand(1000...9999)),
        # Since automated, all accounts will have unlimited everything as default settings
        unlimited_usage_mb_up: true,
        unlimited_usage_mb_down: true,
        unlimited_usage_minutes: true,
        no_usage_expiration: true,
        unlimited_devices: true
      })
    end

    api_post(payload, scaffold)
  end

  # Creates 1 to 4 devices for the last accounts
  def create_device(device_count)
    scaffold = 'devices'
    accounts_array = api_get_body('accounts').last(device_count)
    
    payload = []
    accounts_array.each do |account|
      rand(4).times do # Count of device is random, but will create for the last accounts
        payload.push({
          name: @device_pool[rand(@device_pool.length)],
          mac: @hexadecimal_charset.shuffle!.join[0...12],
          account: { id: account['id'] }
        })
      end
    end
    
    api_post(payload, scaffold)
  end

  def create_account_group(group_count)
    scaffold = 'account_groups'

    payload = []
    group_count.times do 
      payload.push({
        name: @account_group_pool[rand(@account_group_pool.length)],
        priority: 4
      })
    end

    api_post(payload, scaffold)
  end

end