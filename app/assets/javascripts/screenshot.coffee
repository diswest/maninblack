window.screenshot_lock = false

$ ->
  $('body').on 'click', '@screenshot', ->
    return if window.screenshot_lock

    window.screenshot_lock = true
    $('@screenshot').addClass('loader')
    html2canvas($('body')).then (canvas) ->
      $.ajax '/share',
        type: 'POST',
        dataType: 'json',
        timeout: 10000
        data:
          image: canvas.toDataURL()
        complete: ->
          window.screenshot_lock = false
          $('@screenshot').removeClass('loader')
        success: (response) ->
          return unless response.image

          $('meta[property="og:image"]').attr('content', response.image)
          $('meta[name="twitter:image"]').attr('content', response.image)
          $('meta[itemprop="image"]').attr('content', response.image)
          $('@sharing_tags_share').each ->
            $(@).attr('data-image', response.image)

          $('@screenshot').hide()
          $('@sharing-result').show()