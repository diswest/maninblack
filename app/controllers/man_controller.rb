class ManController < ApplicationController

  def index
    @device = env['mobvious.device_type']

    return unless params[:url]

    url = get_url
    parsed_url = URI.parse(url)

    begin
      res = HTTParty.get(url, headers: {
        'User-Agent' => request.user_agent
      })
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
    @result = false unless params[:url]

    url = get_url
    parsed_url = URI.parse(url)

    begin
      HTTParty.get(parsed_url)
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

  def save_share_image
    return unless params[:image]

    image = Base64.decode64(params[:image].split(',')[1])

    return unless validate_image(image)

    filename = Digest::MD5.hexdigest("#{Time.now.to_i}#{rand(100000..999999)}")
    shares_path = "#{Rails.public_path}/uploads/shares"
    file = "#{shares_path}/#{filename}.png"

    File.open(file, 'wb') do|f|
      f.write(image)
    end

    respond_to do |format|
      format.json {
        render json: {
          image: "/s/#{filename}.png",
        }
      }
    end
  end

  private

  def validate_image(image)
    img   = Magick::Image.from_blob(image).first
    fmt   = img.format

    fmt.downcase == 'png' ? true : false
  end

  def get_url()
    url = (params[:url][0..3] == 'http') ? params[:url] : "http://#{params[:url]}"
    url.strip
  end

  def replace_images!(doc, parsed_url)
    doc.css('img').each do |img|
      if img.attributes['src']
        unless is_logo_image?(img)
          img.attributes['src'].value = view_context.image_url('maninblack.jpg')
          img.attributes['srcset'].value = view_context.image_url('maninblack.jpg') if img.attributes['srcset']
        else
          if is_relative_link?(img.attributes['src'].value)
            img.attributes['src'].value = "#{parsed_url.scheme}://#{parsed_url.host}#{img.attributes["src"].value}"
          end
        end
        img.set_attribute('style', '{max-width: 100%; max-height: 100%;}')
        img.attributes['data-original'].value = view_context.image_url('maninblack.jpg') if img.attributes['data-original']
      end
    end

    replace_meduza_images!(doc, parsed_url) if parsed_url.host == 'meduza.io'
    replace_slon_images!(doc, parsed_url) if parsed_url.host == 'slon.ru'

    doc.css('source').each do |source|
      if source.attributes['srcset'] and (
        source.attributes['srcset'].value.include?('.jpg') or
        source.attributes['srcset'].value.include?('.png')
      )
        source.attributes['srcset'].value = view_context.image_url('maninblack.jpg')
      end
    end
  end

  def replace_meduza_images!(doc, parsed_url)
    doc.css('div.NewsEntryImage').each do |img|
      if img.attributes['style']
        img.attributes['style'].value = "background-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url(#{view_context.image_url('maninblack.jpg')})"
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
      if meta.attributes['http-equiv'] and meta.attributes['http-equiv'].value.downcase == 'content-type' \
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
