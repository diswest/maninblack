# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  if window.location.hash
    $('@content').addClass('result')
    $('@urlfield').val(window.location.hash.substring(1))
    window.app.request()

  $('body').on 'click', '@button', ->
    window.app.request()

  $('@urlfield').on 'keypress', (e) ->
    $('@form').removeClass('error')
    window.app.request() if e.which == 13

  $('@urlfield').on 'focus', ->
    $('@form').removeClass('error')

window.app = window.app || {}
window.app.request = ->
  $('@urlfield').attr('readonly', 'readonly')
  $('@form').addClass('loader')
  $.ajax '/validate',
    type: 'GET',
    dataType: 'json',
    timeout: 10000
    data:
      url: $('@urlfield').val()
    complete: ->
      $('@form').removeClass('loader')
      $('@urlfield').removeAttr('readonly')
    error: ->
      $('@form').addClass('error')
    success: (response) ->
      if !response.success
        $('@form').addClass('error')
      else
        url = $('@urlfield').val()
        $('@form').removeClass('error')
        $('@viewport').attr('src', "/?url=#{url}")
        $('@content').addClass('transient')

        window.location.hash = "##{url}";

        setResultClass = ->
          $('@content').removeClass('transient')
          $('@content').addClass('result')

        setTimeout(setResultClass, 1200)
