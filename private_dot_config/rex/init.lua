-- Rex configuration. Reload after editing with `rex config reload`.

-- Quick-look floats: open a TUI in a floating layer over the current window,
-- in the focused pane's working directory. Quitting the program closes the
-- float. Each one appears in the command palette under its title.

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"
local FLOAT_BOUNDS = { 0.05, 0.05, 0.9, 0.9 } -- x, y, w, h as window fractions

-- Return the focused terminal's working directory as a plain path, or nil
-- when the focused block is not a terminal or has not reported one.
local function focused_cwd(ctx)
  if ctx.block_id == nil then
    return nil
  end
  local r = rex.block.call(TERMINAL, "pwd", { block_id = ctx.block_id })
  if r == nil or r.pwd == nil then
    return nil
  end
  -- pwd is a file:// URL such as file://host/Users/me/dir%20name
  local path = r.pwd:match("^file://[^/]*(/.*)$")
  if path == nil then
    return nil
  end
  return (path:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end))
end

-- alias is a short palette search term, shown in the title and matched as a keyword.
local function float_tool(name, alias, argv)
  rex.action{
    name = "float_" .. name,
    title = "Float: " .. name .. " (" .. alias .. ")",
    category = "Float",
    keywords = "float popup quick " .. name .. " " .. alias,
    run = function(ctx, args)
      local layer, err = rex.session.new_layer{
        bounds = FLOAT_BOUNDS,
        layout = rex.layout.block{
          flavor = SHELL,
          label = name,
          options = { command = argv, cwd = focused_cwd(ctx) },
        },
        focus = true,
      }
      if err ~= nil then
        error(err, 0)
      end
      return { layer_id = layer.layer_id, block_id = layer.block_ids[1] }
    end,
  }
end

float_tool("lazygit", "lg", { "lazygit" })
float_tool("yazi", "yy", { "yazi" })
float_tool("btop", "bt", { "btop" })
