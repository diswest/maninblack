default_share = @SharingTags.prototype.share

@SharingTags.prototype.share = ->
  binded_share = default_share.bind(@)

  html2canvas($('@viewport')).then (canvas) ->
    $.ajax '/share',
      type: 'POST',
      dataType: 'json',
      timeout: 10000
      data:
        image: canvas.toDataURL()
      success: (response) ->
        return unless response.image

        $('meta[property="og:image"]').attr('content', response.image)
        $('meta[name="twitter:image"]').attr('content', response.image)
        $('meta[itemprop="image"]').attr('content', response.image)

        binded_share()

  return @
