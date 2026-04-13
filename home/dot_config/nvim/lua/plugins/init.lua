return {
	-- disable default plugins
	{ "folke/flash.nvim", enabled = false },
	{ "catppuccin/nvim", enabled = false },
	{ "folke/tokyonight.nvim", enabled = false },

	-- snacks
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				preset = {
					header = [[
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
]],
				},
				enabled = true,
			},
			explorer = { enabled = false },
		},
	},

	-- dracula
	{
		"Mofiqul/dracula.nvim",
		lazy = true,
		opts = {
			-- customize dracula theme colors
			colors = {
				bg = "#000000",
				selection = "#202040",
			},
		},
	},

	-- yazi
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>E",
				function()
					require("yazi").yazi()
				end,
				desc = "Open Yazi",
			},
		},
		opts = {
			-- Enable yazi to replace netrw for directory opening
			open_for_directories = true,
			-- Fullscreen mode
			yazi_floating_window_scaling_factor = 1.0,
		},
	},
}
