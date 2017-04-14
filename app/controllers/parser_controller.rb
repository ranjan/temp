class ParserController < ApplicationController
  require 'mechanize'
  require 'pry'
  ZilloUrl = 'https://www.zillow.com'.freeze

  def get_property_list
    address = params[:address]
    @pa = PropertyAddress.find_or_create_by(address: address)
    search_property(address) if @pa.properties.blank?
  end

  def search_property(address)
    mechanize = Mechanize.new
    begin
      page = mechanize.get(ZilloUrl)
    rescue
      raise 'Site Unreachable'.inspect
    end
    search_page = page.form_with(id: 'formSearchBar') do |form|
      search_field = form.field_with(id: 'citystatezip')
      search_field.value = address
    end.submit
    parse_property_list(search_page)
  end

  def parse_property_list(page)
    puts "Search Page Details: #{page.title} #{page.uri}"
    result = []
    page.css('div.zsg-photo-card-content.zsg-aspect-ratio-content').each do |p|
      attrs = {}
      attrs[:url] = p.css('a').map { |e| e['href'] }.reject(&:empty?).first
      p.css('div.zsg-photo-card-caption').each do |pd|
        type = pd.at('h4.zsg-photo-card-spec > .zsg-photo-card-status')
        price = pd.at('p.zsg-photo-card-spec > .zsg-photo-card-price')
        next unless type &&  price
        attrs[:property_type] = type.text
        attrs[:price] = price.text
        attrs[:address] = pd.at('p.zsg-photo-card-spec > .zsg-photo-card-address').text
        result << attrs
      end
    end
    @pa.properties.build(result)
    @pa.save
  end

  def property_details
    url = ZilloUrl + params[:url]
    @property = Property.find_by(url: params[:url])
    parse_home_details(url) unless @property.property_detail
  end

  def parse_home_details(url)
    mechanize = Mechanize.new
    page = mechanize.get(url)
    detail = {}
    detail[:address] = page.at('.zsg-content-header.addr > h1').text.strip
    detail[:area] = page.at('.zsg-content-header.addr > h3').text.strip
    detail[:description] = page.at('.notranslate.zsg-content-item').text.strip
    facts = {}
    page.css('div.hdp-fact-ataglance-container >  div.zsg-media-bd').each do |p|
      key = p.at('p.hdp-fact-ataglance-heading').text
      value = p.at('div.hdp-fact-ataglance-value').text
      facts[key] = value
    end
    detail[:facts] = facts
    detail[:market_value] = {}
    page.css('.zest-content').each do |zc|
      t = zc.at('.zest-title').children.first.text.strip
      detail[:market_value][t] = {}
      detail[:market_value][t][:value] = zc.at('.zest-value').text
      detail[:market_value][t][:low_range] = zc.css('.zest-range-bar-low').text
      detail[:market_value][t][:high_range] = zc.css('.zest-range-bar-high').text
    end
    @property.build_property_detail(detail)
    @property.save!
  end
end
