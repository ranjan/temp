class ParserController < ApplicationController
  require 'mechanize'
  require 'pry'	
  ZilloUrl = 'https://www.zillow.com'.freeze

  def get_property_list
  	address = params[:address]
    mechanize = Mechanize.new
    begin
     page = mechanize.get(ZilloUrl)
    rescue 
      puts 'Site Unreachable'
    end   
    search_page = page.form_with(id: 'formSearchBar') do |form|
      search_field = form.field_with(id: 'citystatezip')
      search_field.value = address
    end.submit
    @results = parse_property_list(search_page)
  end

  def parse_property_list(page)
    puts "Search Page Details: #{page.title} #{page.uri}"
    result = []
    page.css('div.zsg-photo-card-content.zsg-aspect-ratio-content').each do |p|
      attrs = {}
      attrs[:url] = p.css('a').map{|e| e["href"]}.reject(&:empty?).first
      p.css('div.zsg-photo-card-caption').each do |pd|
      	type = pd.at('h4.zsg-photo-card-spec > .zsg-photo-card-status')
      	next unless type
        attrs[:type] = type.text
        attrs[:value] = pd.css('p.zsg-photo-card-spec > .zsg-photo-card-price').text
        attrs[:address] = pd.at('p.zsg-photo-card-spec > .zsg-photo-card-address').text
        binding.pry if attrs[:url].empty?
        result << attrs
      end
    end
    result
  end

  def parse_home_details
  	url = ZilloUrl + params[:url]
    mechanize = Mechanize.new
    page = mechanize.get(url)
    @detail = {}
    @detail[:address] = page.at('.zsg-content-header.addr > h1').text.strip
    @detail[:area] = page.at('.zsg-content-header.addr > h3').text.strip
    @detail[:description] = page.at('.notranslate.zsg-content-item').text.strip
    facts = {}
    page.css('div.hdp-fact-ataglance-container >  div.zsg-media-bd').each do |p|
      key = p.at('p.hdp-fact-ataglance-heading').text
      value = p.at('div.hdp-fact-ataglance-value').text 
      facts[key] = value
      #binding.pry
    end
    @detail[:facts] = facts
    #page.css('div.hdp-facts.zsg-content-component.z-moreless > div.hdp-facts-expandable-container > div.zsg-media-bd').each do |x|
    #  fact = x.css('h3').text
    #  facts = []
    #  x.css('ul').each do |ul|
    #    facts << ul.css('li').children.select(&:text?).collect(&:text).reject(&:empty?)
    #  end
    #  @detail[fact.to_sym] = facts.flatten
    #  binding.pry
    #end
    page.css('.zest-content').each do |zc|
      t = zc.at('.zest-title').children.first.text.strip
      @detail[t] = {}
      @detail[t][:value] = zc.at('.zest-value').text
      @detail[t][:low_range] = zc.css('.zest-range-bar-low').text
      @detail[t][:high_range] = zc.css('.zest-range-bar-high').text
    end
    @detail
  end

end
