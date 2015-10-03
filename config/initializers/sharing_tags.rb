SharingTags.configure do
  facebook do
    app_id '462173197303481'
  end

  title { 'Властелин' }
  description { 'Кажется, вам снова есть, через что читать' }
  image('1200x630', 'image/png') do
    asset_url('sharing_fb.png')
  end

  vkontakte do
    image('1200x630', 'image/png') do
      asset_url('sharing_vk.png')
    end
  end

  twitter do
    page_url 'http://vlastelin.io'
    share_url 'http://vlastelin.io'

    image('1200x630', 'image/png') do
      asset_url('sharing_vk.png')
    end
  end

  page_url { root_url }
end
