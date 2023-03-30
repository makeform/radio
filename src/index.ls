module.exports =
  pkg:
    name: "@makeform/radio", extend: name: '@makeform/common'
    i18n:
      en: "其它": "Other"
      "zh-TW": "其它": "其它"
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
        "other-prompt": ({node}) ~>
          if @mod.info.config.{}other.prompt => return that
          else return t("其它")

      action:
        input: "other-text": ({node}) ~> @value node.value
        change: "other-radio": ({node, ctx}) ~>
          if @value! in (@mod.info.config.values or []) or !@value! => @value ''

      handler:
        input: ({node}) ~> node.classList.toggle \text-danger, @status! == 2
        other: ({node}) ~> node.classList.toggle \d-none, !(@mod.info.config.{}other.enabled)

        "other-radio": ({node}) ~>
          node.setAttribute \name, id
          if !@mod.info.meta.readonly => node.removeAttribute \disabled
          else node.setAttribute \disabled, null
          node.checked = !(@value! in (@mod.info.config.values or []))
        "other-text": ({node}) ~>
          if !@mod.info.meta.readonly => node.removeAttribute \readonly
          else node.setAttribute \readonly, null
          v = @value!
          node.value = if v in (@mod.info.config.values or []) => '' else if v? => v else ''
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

