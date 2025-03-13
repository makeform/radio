# @makeform/radio

Radio style widget for users to make one single choice between multiple options.


## Configs

 - `values`: Array of string/objects for options in this widget.
   - when object is used, it contains following fields:
     - `value`: actual value picked
     - `label`: text shown for user to select
 - `other`: default null. An object for config of `other` option, with following fields:
   - `enabled`: default false. should `other` option be shown.
   - `prompt`: default `其它` or `Other`. Prompt text for `other` option.
 - `layout`: default `inline`. decide how to layout options. possible values: either `inline` or `block`.


## License

MIT
