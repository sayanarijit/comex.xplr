local function parse_args(args)
  if args == nil then
    args = {}
  end

  if args.compress_key == nil then
    args.compress_key = "C"
  end

  if args.extract_key == nil then
    args.extract_key = "X"
  end

  if args.compressors == nil then
    args.compressors = {}
  end

  if args.keep_selection == nil then
    args.keep_selection = false
  end

  for _, compressor in ipairs{
    { "enter", "tar", [[cat "${XPLR_PIPE_SELECTION_OUT:?}" | xargs -l basename | tar -C "$PWD" -cf _xplr_archive.tar -T -]] },
    { "z", "tar.gz", [[cat "${XPLR_PIPE_SELECTION_OUT:?}" | xargs -l basename | tar -C "$PWD" -czf _xplr_archive.tar.gz -T -]] },
    { "J", "tar.xz", [[cat "${XPLR_PIPE_SELECTION_OUT:?}" | xargs -l basename | tar -C $PWD -cJf _xplr_archive.tar.xz -T -]] },
    { "j", "tar.bzip2", [[cat "${XPLR_PIPE_SELECTION_OUT:?}" | xargs -l basename | tar -C $PWD -cjf _xplr_archive.tar.bzip2 -T -]] },
  } do
    local key = compressor[1]
    local extension = compressor[2]
    local cmd = compressor[3]
    if args.compressors[key] == nil then
      args.compressors[key] = { extension = extension, command = cmd }
    end
  end
  -- TODO: Add more options

  if args.extractors == nil then
    args.extractors = {}
  end

  for _, extractor in ipairs{
    { "enter", "tar", "tar -xf ${XPLR_FOCUS_PATH:?}" },
    { "z", "tar.gz", "tar -xzf ${XPLR_FOCUS_PATH:?}" },
    { "J", "tar.xz", "tar -xJf ${XPLR_FOCUS_PATH:?}" },
    { "j", "tar.bzip2", "tar -xjf ${XPLR_FOCUS_PATH:?}" },
  } do
    local key = extractor[1]
    local extension = extractor[2]
    local cmd = extractor[3]
    if args.extractors[key] == nil then
      args.extractors[key] = { extension = extension, command = cmd }
    end
  end
  -- TODO: Add more options

  return args
end

local function basic_mode(name)
  return {
    name = name,
    key_bindings = {
      on_key = {
        esc = {
          help = "cancel",
          messages = { "PopMode" }
        },
        ["ctrl-c"] = {
          help = "terminate",
          messages = { "Terminate" }
        }
      }
    }
  }
end

local function mode_switcher(name)
  return {
    help = name,
    messages = {
      "PopMode",
      { SwitchModeCustom = "comex_" .. name },
    }
  }
end

local function setup(args)
  local xplr = xplr
  args = parse_args(args)

  xplr.config.modes.custom.comex_compress = basic_mode("compress")
  xplr.config.modes.custom.comex_extract = basic_mode("extract")

  for key_c, val_c in pairs(args.compressors) do
    xplr.config.modes.custom.comex_compress.key_bindings.on_key[key_c] = {
      help = val_c.extension,
      messages = {
        { BashExec = val_c.command },
        { FocusPath = "_xplr_archive." .. val_c.extension },
        "ClearSelection",
        "PopMode",
      }
    }
  end

  for key_x, val_x in pairs(args.extractors) do
    xplr.config.modes.custom.comex_extract.key_bindings.on_key[key_x] = {
      help = val_x.extension,
      messages = {
        { BashExec = val_x.command },
        "PopMode",
      }
    }
  end

  xplr.config.modes.builtin.selection_ops.key_bindings.on_key[args.compress_key] = mode_switcher("compress")
  xplr.config.modes.builtin.action.key_bindings.on_key[args.extract_key] = mode_switcher("extract")

end

return { setup = setup }
