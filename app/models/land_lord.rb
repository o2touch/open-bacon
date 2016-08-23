# Master of all the tenants. 
# Roll up roll up get your tenanted shit here.
class LandLord


  #lolsorz #whatnottodo #ensuredifferencesbetweentestingandproduction #youguyswillneverseethiscoming
  #imawinner #TS
  def self.method_missing(method, *args, &block)
    if Rails.env.test?
      return LandLord.default_tenant if method =~ /[a-z_]+_tenant/ && args.count == 0
    end

    super
  end

  # some magic to tenantify any method that returns an array of tenated shit
  def method_missing(method, *args, &block)
    if args.count == 1 && args.first.respond_to?(method)
      # grab the array from the object
      resp_arr = args.first.send(method)
      # return everything, if we're returning all tenants
      return resp_arr if @all_tenants 
      # otherwise filter it first
      return resp_arr.select{|o| o.tenant_id == @tenant.id } 
    end

    super
  end

  # Convenience method to get the default tenant
  def self.default_tenant
    Tenant.find(TenantEnum::MITOO_ID)
  end

  # *********
  # *** Looking for magic about why this methods return the Mitoo tenant in Testing?? *****
  # *** Look up there ^^^^^^^ at self.method_missing 
  # ********
  # Create methods to return each tenant
  if Tenant.table_exists? # for migrating etc
  # define Landlord.mitoo_tenant type methods to return tenants
    Tenant.all.each do |t|
      define_singleton_method "#{t.name}_tenant" do
        Tenant.find(t.id)
      end
    end
  end

  # create this motherfucker, with a tenant set (or all tenants)
  def initialize(object_or_tenant_or_subdomain)
    # return data for one tenant, not all tenants
    @all_tenants = false

    # we got something tenantable
  	if object_or_tenant_or_subdomain.respond_to? :tenant
  		@tenant = object_or_tenant_or_subdomain.tenant

    # we got a tenant
  	elsif object_or_tenant_or_subdomain.is_a? Tenant
	  	@tenant = object_or_tenant_or_subdomain

    # we got a mobile app
    elsif object_or_tenant_or_subdomain.is_a? MobileApp
      # this is because there is not a one to one relationship between apps and tenants,
      #  for now we only need, all tenants (the mitoo app), or the O2 Touch tenant. In
      #  future we'll probably need to return data for an arbitrary number of tenants,
      #  until then let's just use this shitty @all_tenants thing. 
      if object_or_tenant_or_subdomain.tenants.count == 1
        @tenant = object_or_tenant_or_subdomain.tenants.first 
      else
        @tenant = nil
        @all_tenants = true
      end

    # we got a string (let's assume it's a subdomain)
	  elsif object_or_tenant_or_subdomain.is_a? String
	  	@tenant = Tenant.find_by_subdomain(object_or_tenant_or_subdomain)

    # we got in integer (let's assume it's a tenant id)
    elsif object_or_tenant_or_subdomain.is_a? Integer
      @tenant = Tenant.find_by_id(object_or_tenant_or_subdomain)
	  else
      # bit of a hack, because we SO MANY tests that don't take into account tenants,
      #  (eg. passing in a mock as what we're trying to get the tenant from), so let's 
      #  just make it so they don't have to. Brap. TS
      if Rails.env.test?
        return self.class.default_tenant if object_or_tenant_or_subdomain.is_a? RSpec::Mocks::Mock
      end
	  	raise "LandLord cannot find tenant from supplied arg"
	  end

	  # just return the default if the subdomain, or id was wrong.
    #  (so we don't have to worry about exceptions etc.)
  	@tenant = self.class.default_tenant if @tenant.nil? 
  end

  # this is based on what we're viewing, not what the current user is, etc.
  def tenant
    @tenant
  end

  def is_same_tenant_as?(obj)
    raise "Not Tenanted" unless obj.respond_to? :tenant_id
    return true if @all_tenants == true
    obj.tenant_id == @tenant.id
  end
end