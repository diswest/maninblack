SharingTags.configure do
  facebook do
    app_id '1627337934188797'
  end

  title { 'Vlastelin.io' }
  description { 'Твой интернет уже не будет прежним' }
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

    title "#Vlastelin \n Твой интернет уже не будет прежним"

    image('1200x630', 'image/png') do
      asset_url('sharing_vk.png')
    end
  end

  page_url { root_url }
end
