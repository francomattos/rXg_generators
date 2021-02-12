require_relative 'class_constant_variables'
# Methods are found on separate files based on menu item they manage
require_relative 'identities'
require_relative 'network'
require_relative 'system'

# This is the main class for handling local requests using Ruby on Rails console
# If you encounter errors, ensure it is installed under space/rxg/console/tools/
class RxgLocal
  include ClassConstantVariables # Constant variables defined in another file
  # These are the create methods
  include Network
  include Identities
  include System

  def initialize
    # initializes rails environment
    require File.join(File.dirname(__FILE__), '../../config/boot_script_environment')
  end

  def create_entry(payload_array, scaffold)
    # Converts table name to model name
    table_model = scaffold.singularize.camelize.constantize

    payload_array.each do |payload|
      # Checks for differences between API and model format
      payload = check_payload_keys(payload)
      table_model.create!(payload)
    end
  end

  # Returns the body of get request, with option for passing a hash for filtering parameters
  def get_table(scaffold, **filters)
    # Converts table name to model name
    table_model = scaffold.singularize.camelize.constantize
    json_body = table_model.all.as_json # Returns table in hash format

    if filters.any?
      filters.each do |name, value|
        json_body.keep_if { |return_item| return_item[name.to_s] == value.to_s }
      end
    end

    json_body
  end

  private 
  def check_payload_keys(payload)
    # Overrides key mismatches between API and rails model
    if payload.key?(:infrastructure_device)
      payload[:infrastructure_device_id] = payload.delete(:infrastructure_device)
    elsif payload.key?(:account_group)
      payload[:account_group_id] = payload[:account_group][:id]
      payload.delete(:account_group)
    elsif  payload.key?(:account)
      payload[:account_id] = payload[:account][:id]
      payload.delete(:account)
    elsif  payload.key?(:admin_role)
      payload[:admin_role_id] = payload[:admin_role]['id']
      payload.delete(:admin_role)
    elsif payload.key?(:certificate_authority)
      payload[:certificate_authority_id] = payload[:certificate_authority]['id']
      payload.delete(:certificate_authority)
    elsif payload.key?(:ssl_key_chain)
      payload[:ssl_key_chain_id] = payload[:ssl_key_chain]['id']
      payload.delete(:ssl_key_chain)
    end

    payload
  end
end
