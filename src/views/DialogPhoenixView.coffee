# 
class DialogPhoenixView

  render: (viewModel) ->
    @renderButton viewModel
    @renderDialog viewModel
    @monitorBookmarklet viewModel
    @showWelcomeTip viewModel

  renderButton: (viewModel) ->
    buttonTemplate = ->
      ul ->
        li '#filter-button', 'data-bind': 'css: { active: visible() }', ->
          a 'data-bind': 'click: toggleVisible', ->
            messages.get('filter')
    
    $('#global-nav').append CoffeeKup.render buttonTemplate
    ko.applyBindings viewModel, $('#filter-button')[0]

  dialogTemplate: ->
    div '#filter-dialog-container.twttr-dialog-container.draggable', ->
      div '#filter-dialog.twttr-dialog', ->
        div '.twttr-dialog-header', ->
          h3 -> messages.get('filter_dialog_title')
          div '.twttr-dialog-close', 'data-bind': 'click: toggleVisible', ->
            b -> '\u0026times;'
        div '.twttr-dialog-inside', ->
          div '.twttr-dialog-body', ->
            div '.twttr-dialog-content', ->
              fieldset ->
                a '.btn.filter-list-label', 
                  'data-bind': 'text: termsExcludeText, click: toggleTermsExclude'
                div '.filter-list-label', -> 
                  '&nbsp;' + messages.get('tweets_terms') + ':'
                input '.filter-terms-list', 
                  'type': 'text' 
                  'data-bind' : "value: termsList, valueUpdate: ['change', 'afterkeydown']"
                div -> '&nbsp;'
                a '.btn.filter-list-label',
                  'data-bind': 'text: usersExcludeText, click: toggleUsersExclude'
                div '.filter-list-label', -> 
                  '&nbsp;'+ messages.get('tweets_users') + ':'
                input '.filter-users-list', 
                  'type': 'text'
                  'data-bind' : "value: usersList, valueUpdate: ['change', 'afterkeydown']"
                label '.checkbox', ->
                  input
                    'type': 'checkbox'
                    'data-bind' : "checked: showReportView"
                  span 'data-bind': 'click: toggleShowReportView', -> messages.get('show_report_view')
          div '.twttr-dialog-footer', ->
            div '.filter-dialog-footer-right', ->
              a '.filter-bookmarklet',
                'data-bind': 'attr: {href: bookmarklet}', -> messages.get('bookmarklet_text')
              a '.btn', 
                'data-bind': 'text: toggleText, click: toggleEnabled'
            div '.filter-dialog-footer-left', ->
              a '.btn', 
                'data-bind': 'click: clear', -> messages.get('clear')

  renderDialog: (viewModel) ->
    dialogHtml = CoffeeKup.render @dialogTemplate
    viewModel.visible.subscribe (visible) =>
      @toggleVisible visible, dialogHtml, viewModel, appendTo: 'body', center: true

  toggleVisible: do ->
    container = null
    overlay = $('<div class="twttr-dialog-overlay"></div>').appendTo $('body')
    (visible, dialogHtml, viewModel, options) ->
      if  visible
        $('body').addClass 'modal-enabled'
        overlay.show()
        container = $(dialogHtml).appendTo $(options.appendTo)

        if options.center
          dialog = $('#filter-dialog')
          dialog
            .css('position', 'absolute')
            .css('top', (($(window).height() - dialog.outerHeight()) / 2) + 'px')
            .css('left', (($(window).width() - dialog.outerWidth()) / 2) + 'px')

        container.draggable handle: '.twttr-dialog-header'
            
        # Stop propagation of events captured by Twitter.
        container.on 'keydown keypress', (event) ->
          event.stopPropagation()
        
        # Tips
        container.find('.filter-terms-list')  .tipsy gravity: 'w', trigger: 'focus', html: true, fallback: messages.get('filter_terms_list_title')
        container.find('.filter-users-list')  .tipsy gravity: 'w', trigger: 'focus', html: true, fallback: messages.get('filter_users_list_title')
        container.find('.filter-bookmarklet') .tipsy gravity: 'n', trigger: 'hover', html: true, fallback: messages.get('bookmarklet_title')
        
        # Reload and bind
        viewModel.reload()
        ko.applyBindings viewModel, container[0]

      else
        container.find('.filter-terms-list')  .tipsy 'hide'
        container.find('.filter-users-list')  .tipsy 'hide'
        container.find('.filter-bookmarklet') .tipsy 'hide'

        ko.cleanNode container[0]

        container.remove()
        overlay.hide()
        $('body').removeClass 'modal-enabled'

  # Monitor bookmarklet execution
  monitorBookmarklet: (viewModel) ->
    $('#filter-button').on 'DOMNodeInserted', (event) ->
      el = $(event.target)
      viewModel.bookmarkletLoaded(el.data('version'))
      el.remove()

  showWelcomeTip: (viewModel) ->
    if viewModel.showWelcomeTip()
      setTimeout(=>
        $('#filter-button')
          .tipsy(gravity: 'n', trigger: 'manual', html: true, fallback: messages.get('welcome_tip'))
          .tipsy('show')
          .click ->
            $(@).tipsy 'hide'
        
        setTimeout(->
          $('#filter-button').tipsy 'hide'
        , 30000)
        viewModel.showWelcomeTip false
      , 3000)
