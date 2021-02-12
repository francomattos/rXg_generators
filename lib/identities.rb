# Expands rXg_API.rg
# Contains the methods for creating scaffold objects under Identities menu
module Identities
  # Creating an account will also create 1 account group and several devices tied to accounts
  def create_account(account_count)
    scaffold = 'accounts'
    groups_array = get_table('account_groups')
    account_group = nil

    # If there are groups created, use the last created one
    if groups_array.any?
      account_group = {
        name: groups_array.last['name'],
        id: groups_array.last['id'],
        priority: groups_array.last['priority']
      }
    end

    payload = []

    account_count.times do
      first_name = self.class::FIRST_NAME_POOL[rand(self.class::FIRST_NAME_POOL.size)]
      last_name = self.class::LAST_NAME_POOL[rand(self.class::LAST_NAME_POOL.size)]
      random_uid = rand(9999).to_s
      login = first_name.chr.downcase + last_name.downcase + random_uid # Must be unique, so has to have appended uid
      email = first_name.chr.downcase + last_name.chr.downcase + random_uid + '@' + self.class::EMAIL_DOMAIN_POOL[rand(self.class::EMAIL_DOMAIN_POOL.size)]
      user_password = self.class::ALPHANUMERIC_CHARSET.shuffle!.join[0...10]

      payload.push(
        login: login,
        password: user_password,
        password_confirmation: user_password,
        email: email,
        first_name: first_name,
        last_name: last_name,
        account_group: account_group,
        phone: format('%i%i%i', rand(200...700), rand(100...999), rand(1000...9999)),

        # Since automated, all accounts will have unlimited everything as default settings
        unlimited_usage_mb_up: true,
        unlimited_usage_mb_down: true,
        unlimited_usage_minutes: true,
        no_usage_expiration: true,
        unlimited_devices: true
      )
    end

    create_entry(payload, scaffold)
  end

  # Creates 1 to 4 devices for the last created accounts
  def create_device(device_count)
    scaffold = 'devices'
    accounts_array = get_table('accounts').last(device_count)
    payload = []

    accounts_array.each do |account|
      rand(4).times do # Creates up to four devices per account
        payload.push(
          name: self.class::DEVICE_POOL[rand(self.class::DEVICE_POOL.size)],
          mac: self.class::HEXADECIMAL_CHARSET.shuffle!.join[0...12],
          account: { id: account['id'] }
        )
      end
    end

    create_entry(payload, scaffold)
  end

  def create_account_group(group_count)
    scaffold = 'account_groups'
    payload = []
    
    group_count.times do
      payload.push(
        name: self.class::ACCOUNT_GROUP_POOL[rand(self.class::ACCOUNT_GROUP_POOL.size)],
        priority: 4
      )
    end

    create_entry(payload, scaffold)
  end
end
