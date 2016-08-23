cache('all_faft_leagues_sitemap') do
  xml.instruct!
  xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
    
    @leagues.each do |l|
    
      next if l.slug.nil?

      xml.url do
        xml.loc unclaimed_league_url(:league_slug => l.slug, :only_path => false)
        xml.lastmod Date.today.to_date
      end
    end
  end
end