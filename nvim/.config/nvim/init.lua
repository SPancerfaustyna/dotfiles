-- show current line number
vim.opt.number = true

-- show relative number line from current line
vim.opt.relativenumber = true

-- highlight current line number?
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- use terminal true colors
vim.opt.termguicolors = true

-- keep alacritty transparent background
local transparencyGroups = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"SignColumn",
	"EndOfBuffer",
}

for _, group in ipairs(transparencyGroups) do
	vim.api.nvim_set_hl(0, group, {bg = "none"})
end

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = false
