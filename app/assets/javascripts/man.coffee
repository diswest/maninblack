# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('body').on 'click', '@button', ->
    window.app.request()

  $('@urlfield'). on 'keypress', (e) ->
    window.app.request() if e.which == 13

window.app = window.app || {}
window.app.request = ->
  $.ajax '/validate',
    type: 'GET',
    dataType: 'json',
    data:
      url: $('@urlfield').val()
    success: (response) ->
      if !response.success
        $('@form').addClass('error')
      else
        url = $('@urlfield').val()
        $('@form').removeClass('error')
        $('@viewport').attr('src', "/?url=#{url}")
        $('@form').addClass('transient')

        setResultClass = ->
          $('@form').removeClass('transient')
          $('@content').addClass('result')

        setTimeout(setResultClass, 1200)
