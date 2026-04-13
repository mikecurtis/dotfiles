return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		local logo = [[

⣿⡿⠛⠻⣿⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⡇⠘⣠⣶⣾⣶⡆⡁⣴⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⠇⠘⣿⣿⣿⠿⠿⣦⠘⠠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⠘⠰⣿⣿⣿⣄⣠⣿⣷⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣫⡭⢠⣼
⣯⣄⠀⠠⡿⢃⣛⠷⢏⣡⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣡⣿⡟⣰⣿⣿
⣿⣿⣷⡍⣭⣭⣶⣿⣏⣿⡏⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢰⣿⣿⢡⣿⣿⣿
⣿⣿⣿⣷⢸⣿⣿⣿⣿⣿⢳⣌⠻⣿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⢑⢸⣿⣿⢸⣿⣿⣿
⣿⣿⣿⣿⢸⣿⣿⣿⣿⢣⣿⣿⣷⣶⣶⣿⣿⣿⣿⣶⣦⣙⠻⣿⣿⢸⢸⣿⣿⢸⣿⣿⣿
⣿⣿⣿⣿⢸⣿⣿⣿⣏⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡙⢿⡜⣏⣿⣿⡆⢿⣿⣿
⣿⣿⣿⣿⡜⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣛⣭⣭⣛⣿⡌⢧⢹⣞⣿⣿⡘⣿⣿
⣿⣿⣿⣿⣷⡘⢿⣿⡼⣿⣿⣿⣿⡹⣿⣿⣿⢟⣾⣿⣿⣿⣿⣿⣿⡸⣇⢻⡼⣿⣧⢹⣿
⣿⣿⣿⣿⣿⣿⣆⠻⣷⡹⣿⣿⣿⣷⢻⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⡇⣿⡜⡇⣿⣿⢸⣿
⣿⣿⣿⣿⣿⣿⣿⡌⣦⣅⢹⣿⣿⡟⢾⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⠇⣿⢣⣇⣿⣿⢸⣿
⣿⣿⣿⣿⣿⣿⣿⣧⢸⣿⠀⣿⣿⢰⣷⠈⢙⠃⢿⣿⣿⣿⣿⣿⠏⡴⢋⢞⣼⣿⡟⣸⣿
⣿⣿⣿⣿⣿⡿⠛⠡⣾⠏⢁⣿⡇⡞⠁⢰⠶⠒⢂⣙⡿⢿⣿⢵⣤⣤⣶⣿⣿⡟⣰⣿⣿
⣿⣿⣿⣿⣿⣷⣬⣬⣅⠰⠫⠟⣰⣿⣷⣦⢀⠂⠾⠛⢛⣻⣭⣾⣿⣿⡿⠟⣋⣴⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣭⣭⣭⣥⣶⣾⣿⣿⣿⣿⣿

		]]
		dashboard.section.header.val = vim.split(logo, "\n")

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("f", " " .. " Find file", "<cmd> lua LazyVim.pick()() <cr>"),
			dashboard.button("n", " " .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
			dashboard.button("r", " " .. " Recent files", [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
			dashboard.button("g", " " .. " Find text", [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),
			dashboard.button("c", " " .. " Config", "<cmd> lua LazyVim.pick.config_files()() <cr>"),
			dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
			dashboard.button("x", " " .. " Lazy Extras", "<cmd> LazyExtras <cr>"),
			dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
			dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
