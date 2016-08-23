class TenantSubdomain
  def self.matches?(request)

  	tenant_subdomains = %w[o2touchwebapp]
    return true if tenant_subdomains.include?(request.subdomain)

    false
  end
end