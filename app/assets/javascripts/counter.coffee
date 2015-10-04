$ ->
  $(window).on 'sharing_tags.click_action', (event)->
    network = event.network
    context = event.context
    window.yaCounter32846677.reachGoal('start_sharing', {network, context})

  $(window).on 'sharing_tags.success_share', (event, data)->
    if event.network == 'undefined'
      network = data.network
      context = data.context
    else
      network = event.network
      context = event.context

    window.yaCounter32846677.reachGoal('shared', {network, context})
