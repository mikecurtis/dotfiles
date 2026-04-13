return {
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
}
