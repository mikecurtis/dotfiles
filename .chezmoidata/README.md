The file _schema.json provides default values for what should appear in `chezmoi data`.

The "chezmoidata" section should be populated programatically by files in
.chezmoidata/ that are part of the git repo and span across machines.

Machine-local settings (not git backed) can be provided in 
~/.config/chezmoi/chezmoi.toml

That file may override global settings by configuring
[data.chezmoidata]

It can also append values to global lists by configuring
[data.chezmoidata.local]

Clients of this schema are responsible for merging values from the top-level
and from the local section.
