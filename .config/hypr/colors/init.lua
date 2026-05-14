if pcall(require, "colors.colors") then
  return require("colors.colors")
else
  return require("colors.colors_fallback")
end
