-- Unload all im-switch modules before building to avoid stale state
for name, _ in pairs(package.loaded) do
  if name:match("^im%-switch") then
    package.loaded[name] = nil
  end
end

require("im-switch.build").setup()
