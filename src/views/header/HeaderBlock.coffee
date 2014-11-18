MarkerView = require "./MarkerView"
ConservationView = require "./ConservationView"
identityCalc = require "../../algo/identityCalc"
boneView = require("backbone-childs")
_ = require 'underscore'
SeqLogoView = require "biojs-vis-seqlogo"

module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g
    @blockEvents = false

    @listenTo @g.vis,"change:markers change:conserv", ->
      @draw()
      @render()
    @listenTo @g.vis,"change", @_setSpacer
    @listenTo @g.zoomer,"change:alignmentWidth", ->
      @_adjustWidth()
    @listenTo @g.zoomer, "change:_alignmentScrollLeft", @_adjustScrollingLeft

    # TODO: duplicate rendering
    @listenTo @g.columns, "change:hidden", ->
      @draw()
      @render()

    @draw()
    @_onscroll = @_sendScrollEvent

    @g.vis.once 'change:loaded', @_adjustScrollingLeft, @

  events:
    "scroll": "_onscroll"

  draw: ->
    @removeViews()

    unless @isNotDirty
      # only executed when new sequences are added or on start
      consensus = @g.consensus.getConsensus @model
      identityCalc @model, consensus
      @isNotDirty = true

    if @g.vis.get "conserv"
      conserv = new ConservationView {model: @model, g: @g}
      conserv.ordering = -20
      @addView "conserv",conserv

    if @g.vis.get "markers"
      marker = new MarkerView {model: @model, g: @g}
      marker.ordering = -10
      @addView "marker",marker

    counts = []
    for i in [0..100]
      counts.push ["A:0.25", "C:0.25", "G:0.25","T:0.25"]

    data =
      alphabet: "aa"
      height_arr: counts


    colorSelector = require("biojs-util-colorschemes").selector
    seqlogo = new SeqLogoView {model: @model, g: @g, data: data, yaxis: false
    ,xaxis: false, height: 100, colors:colorSelector.getColor(@g.colorscheme.get("scheme"))}
    seqlogo.ordering = -30
    @addView "seqlogo",seqlogo

  render: ->
    @renderSubviews()

    @_setSpacer()

    @el.className = "biojs_msa_header"
    @el.style.overflowX = "auto"
    @_adjustWidth()
    @_adjustScrollingLeft()
    @

  # scrollLeft triggers a reflow of the whole area (even only get)
  _sendScrollEvent: ->
    unless @blockEvents
      @g.zoomer.set "_alignmentScrollLeft", @el.scrollLeft, {origin: "header"}
    @blockEvents = false

  _adjustScrollingLeft: (model,value,options) ->
    if (not options?.origin?) or options.origin isnt "header"
      scrollLeft = @g.zoomer.get "_alignmentScrollLeft"
      @blockEvents = true
      @el.scrollLeft = scrollLeft

  _setSpacer: ->
    # spacer / padding element
    @el.style.marginLeft = @_getLabelWidth() + "px"

  _getLabelWidth: ->
    paddingLeft = 0
    paddingLeft += @g.zoomer.get "labelWidth" if @g.vis.get "labels"
    paddingLeft += @g.zoomer.get "metaWidth" if @g.vis.get "metacell"
    return paddingLeft

  _adjustWidth: ->
    @el.style.width = @g.zoomer.get("alignmentWidth") + "px"
