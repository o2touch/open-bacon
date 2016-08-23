xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  
  @team_urls.each do |url|
    xml.url do
      xml.loc url
      xml.lastmod Date.today.to_date
    end
  end
end