# Expands rXg_API.rg
# Contains the methods for creating scaffold objects under System menu

class RxgAPI
  def create_admin(admin_count)
    scaffold = 'admins'
    admin_role_array = []

    # Gets the currently defined roles for us to use
    # Rg Nets and Super User roles will not be created, so they are filtered out
    api_get_body('admin_roles').each do |admin_role|
      admin_role_array.push(admin_role) unless ['RG Nets', 'Super User'].include?(admin_role['name'])
    end

    payload = []

    admin_count.times do
      first_name = FIRST_NAME_POOL[rand(FIRST_NAME_POOL.size)]
      last_name = LAST_NAME_POOL[rand(LAST_NAME_POOL.size)]
      random_uid = rand(9999).to_s
      login = first_name.chr.downcase + last_name.downcase + random_uid # Must be unique, so has to have appended uid
      email = first_name.chr.downcase + last_name.chr.downcase + random_uid + '@' + EMAIL_DOMAIN_POOL[rand(EMAIL_DOMAIN_POOL.length)]
      user_password = ALPHANUMERIC_CHARSET.shuffle!.join[0...10]
      admin_role = admin_role_array[rand(admin_role_array.size)]

      payload.push({
        login: login,
        first_name: first_name,
        last_name: last_name,
        password: user_password,
        password_confirmation: user_password,
        admin_role: admin_role,
        email: email,
        department: DEPARTMENT_POOL[rand(DEPARTMENT_POOL.size)]
      })
    end

    api_post(payload, scaffold)
  end

  # Code will only use  one CA, which is RG Nets
  # Gets invoked in code only if it doesn't exist
  def create_certificate_authority
    scaffold = 'certificate_authorities'

    payload = [{
      name: 'RG Nets',
      country: 'US',
      state: 'Nevada',
      locale: 'Reno',
      organization_name: 'RG Nets, Inc.',
      organizational_unit_name: 'Professional Services',
      common_name: 'rgnets.com',
      email_address: 'info@rgnets.com'
    }]
  
    api_post(payload, scaffold)
  end

  def create_cert_signing_req(request_count)
    scaffold = 'certificate_signing_requests'
    certificate_array = api_get_body('ssl_key_chains').last(request_count)
    payload = []

    certificate_array.each do |certificate_object|
      certificate_name = certificate_object['name']
      payload.push({
        :name => certificate_name,
        :sign_mode => 'ca',
        :ssl_key_chain => certificate_object,
        :country => 'US',
        :state => 'Nevada',
        :locale => 'Reno',
        :organization_name => 'RG Nets, Inc.',
        :organizational_unit_name => 'Professional Services',
        :common_name => certificate_name + '.rgnets.com',
        :email_address => 'info@rgnets.com',

      })
    end

    api_post(payload, scaffold)
  end

  def create_certificate(certificate_count)
    scaffold = 'ssl_key_chains'
    certificate_id = api_get_body(scaffold).size
    certificate_authority = api_get_body('certificate_authorities', {name: 'RG Nets'})

    # Checks if RG Nets CA exists, if not it will create it and retreive to use in payload
    if certificate_authority.empty?
      puts 'its empty'
      create_certificate_authority
      certificate_authority = api_get_body('certificate_authorities', {name: 'RG Nets'})
    end

    payload = []

    certificate_count.times do
      certificate_id += 1
      payload.push({
        name: "#{certificate_id} #{MACHINE_NAME_POOL[rand(MACHINE_NAME_POOL.size)]}",
        certificate_authority: certificate_authority[0]
      })
    end

    api_post(payload, scaffold)
  end
end
