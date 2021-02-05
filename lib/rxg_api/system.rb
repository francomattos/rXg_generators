# Expands rXg_API.rg
# Contains the methods for creating scaffold objects under System menu

class RxgAPI
  def create_admin(admin_count)
    scaffold = 'admins'
    admin_role_array = []

    api_get_body('admin_roles').each do |admin_role|
      unless ['RG Nets', 'Super User'].include?(admin_role['name'])
        admin_role_array.push(admin_role)
      end
    end

    payload = []
    admin_count.times do
      first_name = @first_name_pool[rand(@first_name_pool.length)]
      last_name = @last_name_pool[rand(@last_name_pool.length)]
      random_uid = rand(9999).to_s
      login = first_name[0, 1].downcase + last_name.downcase + random_uid # Must be unique, so has to have appended uid
      email = first_name[0, 1].downcase + last_name[0, 1].downcase + random_uid + "@" + @email_domain_pool[rand(@email_domain_pool.length)]
      user_password = @alphanumeric_charset.shuffle!.join[0...10]
      admin_role = admin_role_array[rand(admin_role_array.length)]

      payload.push({
        login: login,
        first_name: first_name,
        last_name: last_name,
        password: user_password,
        password_confirmation: user_password,
        admin_role: admin_role,
        email: email,
        department: @department_pool[rand(@department_pool.length)]
      })
    end

    api_post(payload, scaffold)
  end
end