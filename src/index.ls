module.exports =
  pkg: name: "@makeform/radio", extend: name: '@makeform/common'
  init: (opt) -> opt.pubsub.fire \subinit, mod: mod(opt)
mod = ({root, ctx, data, parent, t, i18n}) ->
  {ldview} = ctx
  lc = {}
  id = "_#{Math.random!toString(36)substring(2)}"
  init: ->
    @on \change, ~> @mod.child.view.render \option
    @mod.child.view = view = new ldview do
      root: root
      text:
        content: ({node}) ~> if @is-empty! => 'n/a' else t(@content!)
      handler:
        input: ({node}) ~> node.classList.toggle \text-danger, @status! == 2
        option:
          list: ~> @mod.info.config.values or []
          key: -> it
          view:
            action: change: radio: ({node, ctx}) ~> if node.checked => @value ctx
            handler: radio: ({node, ctx}) ~>
              node.setAttribute \name, id
              node.checked = @value! == ctx
              if !@mod.info.meta.readonly => node.removeAttribute \disabled
              else node.setAttribute \disabled, null
            text: text: ({node, ctx}) -> t ctx

  render: -> @mod.child.view.render!

