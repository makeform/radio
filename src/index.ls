module.exports =
  pkg:
    name: \@makeform/radio
    extend: name: \@makeform/common
    host: name: \@grantdash/composer
    i18n:
      en:
        "其它": "Other"
        config: other:
          enabled: name: "enable 'other' option", desc: "show an 'other' option when enabled"
      "zh-TW":
        "其它": "其它"
        config: other:
          enabled: name: "使用「其它」選項", desc: "啟用時，顯示一個額外的「其它」選項"
  init: (opt) ->
    opt.pubsub.on \inited, (o = {}) ~> @ <<< o
    opt.pubsub.fire \subinit, mod: mod.call @, opt

mod = ({root, ctx, data, parent, t, i18n, host}) ->
  {ldview} = ctx
  lc = {}
  hitf = ~> @hitf
  getv = (t) -> if typeof(t) == \string => t else (t?value or hitf!totext(t?label))
  value-to-label = (v) ->
    r = (lc[]values).filter(-> getkey(it) == v).0
    r = r?label or if r? => r else if v? => v
    if typeof(r) == \object => return hitf!totext(r)
    else if typeof(r) == \string => t(r) else (r or '')
  inside = (v) ~> v in (lc.values or []).map(-> getkey it)
  id = "_#{Math.random!toString(36)substring(2)}"
  keygen = -> "#{Date.now!}-#{keygen.idx = (keygen.idx or 0) + 1}-#{Math.random!toString(36)substring(2)}"
  getkey = -> it.key or getv(it)
  @client = ->
    minibar: []
    meta: config: other:
      enabled: type: \boolean, name: "config.other.enabled.name", desc: "config.other.enabled.desc"
    render: ~> lc.view.render!
    sample: ~> config: values: [
      * key: keygen!, label: hitf!wrap "#{i18n.language}": 'Option 1'
      * key: keygen!, label: hitf!wrap "#{i18n.language}": 'Option 2'
      * key: keygen!, label: hitf!wrap "#{i18n.language}": 'Option 3'
      ]
  init: ->
    @on \change, ~> @mod.child.view.render \option
    remeta = ~> lc.values = (@mod.info.config or {}).values or []
    remeta!
    @on <[meta]>, ~> remeta!
    @mod.child.view = view = lc.view = new ldview do
      root: root
      text:
        content: ({node}) ~> if @is-empty! => 'n/a' else value-to-label(@value!)
      action:
        input: "other-text": ({node}) ~> @value node.value
        change: "other-radio": ({node, ctx}) ~>
          if inside(@value!) or !@value! => @value ''
        click:
          "other-prompt": hitf!edit obj: ({ctx}) ->
            o = hitf!get!{}config{}other
            o.prompt = if typeof(o.prompt) == \string => {} else (o.prompt or {})
          add: ({node, views}) ~>
            new-entry = do
              label: hitf!wrap "#{i18n.language}": "untitled"
              key: keygen!
            hitf!get!{}config[]values.push new-entry
            hitf!set!
            views.0.render!
      handler:
        "other-prompt": hitf!render obj: ~>
          (if !(p = hitf!get!?config?other?prompt) => ''
          else if typeof(p) != \string => p else p) or \其它
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
          list: ~>
            v = hitf!get!config?values or []
            if Array.isArray(v) => v else if v => [v] else []
          key: -> getkey it
          view:
            action:
              change:
                radio: ({node, ctx}) ~> if node.checked => @value getkey(ctx)
              click:
                "@": ({node, evt}) ->
                  # label dynamics force us to prevent propagation for clicking on editor.
                  if !(node.parentNode and (n = ld$.find(node.parentNode,'[ld=editor]',0))) => return
                  evt.stopPropagation!
                  evt.preventDefault!
                remove: ({node, ctx, views}) ~>
                  cfg = hitf!get!{}config
                  cfg.values = cfg.[]values.filter -> getkey(it) != getkey(ctx)
                  hitf!set!
                text: hitf!edit {obj: ({ctx}) -> ctx.{}label}
            handler:
              "@": ({node}) ~>
                node.style.flexBasis = if (@mod.info.config or {}).layout == \block => "100%" else ''
              radio: ({node, ctx}) ~>
                node.setAttribute \name, id
                node.checked = @value! == getkey(ctx)
                if !@mod.info.meta.readonly => node.removeAttribute \disabled
                else node.setAttribute \disabled, null
              text: hitf!render obj: ({ctx}) -> ctx.label or ctx

  render: -> @mod.child.view.render!
