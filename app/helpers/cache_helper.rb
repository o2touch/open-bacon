module CacheHelper
  def fetch_from_cache(cache_key, &block)
    begin
      Rails.cache.fetch cache_key do
        yield
      end
    rescue
      Rails.cache.delete cache_key
      yield
    end
  end
end