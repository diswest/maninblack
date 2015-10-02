class ManController < ApplicationController

  def index
    return if not params[:url]

    url = (params[:url][0..3] == 'http') ? params[:url] : "http://#{params[:url]}"
    parsed_url = URI.parse(url)

    begin
      res = HTTParty.get(url)
    rescue
      return
    end

    doc = Nokogiri::HTML(res.body)

    replace_images!(doc, parsed_url)
    replace_links!(doc, parsed_url)

    restore_styles!(doc, parsed_url)
    restore_scripts!(doc, parsed_url)

    result = doc.to_html

    response.headers['Content-Type'] = 'text/html; charset=windows-1251' if is_win_charset?(doc)

    render layout: false, text: result
  end

  def validate
    @result = true
    @result = false if not params[:url]

    url = (params[:url][0..3] == 'http') ? params[:url] : "http://#{params[:url]}"
    parsed_url = URI.parse(url)

    begin
      res = HTTParty.get(url)
    rescue
      @result = false
    end

    respond_to do |format|
      format.json {
        render json: {
          success: @result,
        }
      }
    end
  end

  private

  def replace_images!(doc, parsed_url)
    doc.css('img').each do |img|
      if img.attributes['src']
        unless is_logo_image?(img)
          img.attributes['src'].value = view_context.image_url('maninblack.jpg')
        else
          if is_relative_link?(img.attributes['src'].value)
            img.attributes['src'].value = "#{parsed_url.scheme}://#{parsed_url.host}#{img.attributes["src"].value}"
          end
        end
      end

      replace_meduza_images!(doc, parsed_url) if parsed_url.host == 'meduza.io'
      replace_slon_images!(doc, parsed_url) if parsed_url.host == 'slon.ru'
    end
  end

  def replace_meduza_images!(doc, parsed_url)
    doc.css('div.NewsEntryImage').each do |img|
      if img.attributes['style']
        img.attributes['style'].value = "background-image:url(#{view_context.image_url('maninblack.jpg')})"
      end
    end
  end

  def replace_slon_images!(doc, parsed_url)
    doc.css('div.card-cover').each do |img|
      if img.attributes['style']
        img.attributes['style'].value = "background-image:url(#{view_context.image_url('maninblack.jpg')})"
      end
    end
  end

  def replace_links!(doc, parsed_url)
    doc.css('a').each do |link|
      if link.attributes['href']
        if is_relative_link?(link.attributes['href'].to_s)
          replaced_link = "#{request.base_url}?url=#{parsed_url.scheme}://#{parsed_url.host}#{link.attributes["href"].value}"
        else
          replaced_link = "#{request.base_url}?url=#{link.attributes["href"].value}"
        end

        link.attributes['href'].value = replaced_link
      end
    end
  end

  def restore_styles!(doc, parsed_url)
    doc.css('link').each do |link|
      if link.attributes['href'] and is_relative_link?(link.attributes['href'].to_s)
        link.attributes['href'].value = "#{parsed_url.scheme}://#{parsed_url.host}#{link.attributes["href"].value}"
      end
    end
  end

  def restore_scripts!(doc, parsed_url)
    doc.css('script').each do |script|
      if script.attributes['src'] and is_relative_link?(script.attributes['src'].to_s)
        script.attributes['src'].value = "#{parsed_url.scheme}://#{parsed_url.host}#{script.attributes["src"].value}"
      end
    end
  end

  def is_win_charset?(doc)
    doc.css('meta').each do |meta|
      if meta.attributes['http-equiv'] and meta.attributes['http-equiv'].value == 'Content-Type' \
        and meta.attributes['content'].value.include?('1251')

        return true
      end
    end

    false
  end

  def is_relative_link?(link)
    link[0] == '/' and link[0..1] != '//'
  end

  def is_logo_image?(node)
    if node.attributes['class'] and node.attributes['class'].value.include?('logo')
      return true
    end

    if node.attributes['id'] and node.attributes['id'].value.include?('logo')
      return true
    end

    if node.attributes['src'] and node.attributes['src'].value.include?('logo.')
      return true
    end

    false
  end
end
