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
    getv = (t) -> if typeof(t) == \object => t.value else t
    getlabel = (s) -> if typeof(s) == \object => t(s.label) else s
    tolabel = (s) ->
      r = ((lc.values or []).filter(-> getv(it) == s).0 or {}).label
      return if r => t(r) else s
    inside = (v) ~> v in (@mod.info.config.values or []).map(-> getv it)
    @mod.child.view = view = new ldview do
      root: root
      text:
        content: ({node}) ~> if @is-empty! => 'n/a' else tolabel(@content!)
        "other-prompt": ({node}) ~>
          if @mod.info.config.{}other.prompt => return t(that)
          else return t("其它")

      action:
        input: "other-text": ({node}) ~> @value node.value
        change: "other-radio": ({node, ctx}) ~>
          if inside(@value!) or !@value! => @value ''

      handler:
        input: ({node}) ~> node.classList.toggle \text-danger, @status! == 2
        other: ({node}) ~> node.classList.toggle \d-none, !(@mod.info.config.{}other.enabled)

        "other-radio": ({node}) ~>
          node.setAttribute \name, id
          if !@mod.info.meta.readonly => node.removeAttribute \disabled
          else node.setAttribute \disabled, null
          node.checked = !inside(@value!)
        "other-text": ({node}) ~>
          if !@mod.info.meta.readonly => node.removeAttribute \readonly
          else node.setAttribute \readonly, null
          v = @value!
          node.value = if inside(v) => '' else if v? => v else ''
        option:
          list: ~> @mod.info.config.values or []
          key: -> getv(it)
          view:
            action: change: radio: ({node, ctx}) ~> if node.checked => @value getv(ctx)
            handler: radio: ({node, ctx}) ~>
              node.setAttribute \name, id
              node.checked = @value! == getv(ctx)
              if !@mod.info.meta.readonly => node.removeAttribute \disabled
              else node.setAttribute \disabled, null
            text: text: ({node, ctx}) -> getlabel(ctx)

  render: -> @mod.child.view.render!

