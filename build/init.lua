-- Unload im-switch modules to load new files
for module_name, _ in pairs(package.loaded) do
  if module_name:match("^im%-switch") then
    package.loaded[module_name] = nil
  end
end

local build = require("im-switch.build")
build.setup()
