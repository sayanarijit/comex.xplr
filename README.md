[![xplr-comex.gif](https://s6.gifyu.com/images/xplr-comex.gif)](https://gifyu.com/image/A1zD)


Requirements
------------

- [tar](https://www.gnu.org/software/tar)


Installation
------------

### Install manually

- Add the following line in `~/.config/xplr/init.lua`

  ```lua
  package.path = os.getenv("HOME") .. '/.config/xplr/plugins/?/src/init.lua'
  ```

- Clone the plugin

  ```bash
  mkdir -p ~/.config/xplr/plugins

  git clone https://github.com/sayanarijit/comex.xplr ~/.config/xplr/plugins/comex
  ```

- Require the module in `~/.config/xplr/init.lua`

  ```lua
  require("comex").setup()
  
  -- Or
  
  require("comex").setup{
    compress_key = "C",
    compressors = {
      Z = { extension = "zip", command = [[zip $(cat "${XPLR_PIPE_SELECTION_OUT:?}")]] },
    },
    extract_key = "X",
    extractors = {
      Z = { extension = "zip", command = [[unzip -d "${XPLR_FOCUS_PATH:?}.d" "${XPLR_FOCUS_PATH:?}"]] },
    },
    keep_selection = false,
  }

  -- Type `:sC` to compress selection, and `:X` to extract focus.
  ```
