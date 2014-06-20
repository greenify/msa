define [], ->
  class ZoomBar

    constructor: (@msa) ->
      zoomForm = document.createElement("form")
      zoomSlider = document.createElement("input")
      zoomSlider.type = "range"
      zoomSlider.name = "points"
      zoomSlider.min = 1
      zoomSlider.max = 30
      zoomSlider.style.width = "60%"

      zoomSlider.value = @msa.zoomer.level

      zoomForm.appendChild zoomSlider
      @locked = false

      #zoomSlider.addEventListener "change", (evt) =>
      #  @_reDraw()

      zoomSlider.addEventListener "mousemove", (evt) =>
        if @lastValue isnt @zoomSlider.value
          @lastValue = @zoomSlider.value
          unless @locked
            @locked = true
            window.setTimeout @_reDraw,30

      # save for the future
      @zoomSlider = zoomSlider

    _reDraw: =>
      value = @zoomSlider.value
      @msa.zoomer.setZoomLevel(value)
      @msa.config.autofit = false
      @msa.redraw('stage')
      @msa.redraw('marker')
      @locked = false

    draw: ->
      @zoomSlider
