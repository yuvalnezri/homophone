$ ->
  $("[data-infinite-inputs]").each ->
    $this = $(this)
    $clone = $this.find("[data-infinite-inputs-row]:first").clone()
    $clone.find("input").val("")

    appendInput = ->
      $this.append($clone.clone())
      bindLastInput()

    bindLastInput = ->
      $this.find("[data-infinite-inputs-row]:last input:first").one "focus", ->
        appendInput()

    appendInput()

# masonry on cards
$ ->
  $masonry_container  = $(".card-set-container")
  $cards              = $(".card")
  $ad_cards           = $cards.filter(".card-partner")

  $ad_cards.addClass "stamp"

  only_one_word = $cards.length - $ad_cards.length == 1

  window.remason = (setup = false)->
    $masonry_container.masonry "destroy" unless setup

    $masonry_container.masonry
      itemSelector: ".card:not(.stamp)",
      stamp: ".stamp",
      gutter: 9,
      isOriginLeft: only_one_word

  window.remason(true)

  enquire.register "screen and (max-width: #{Homophone.screen_xs_max}px)",
    match: ->
      $ad_cards.removeClass "stamp"
      window.remason()
    unmatch: ->
      $ad_cards.addClass "stamp"
      window.remason()


  $masonry_container.find("iframe").one "load", window.remason

# Share Buttons
$ ->
  $("[data-share-button]").each ->
    $this = $(this)
    options =
      id:      $this.data("id")
      social:  $this.data("social")
      type:    $this.data("type")
      trigger: $this.data("trigger")

    options.url = window.location.host + "/word_sets/" + options.id
    new ShareButton($this, options)
