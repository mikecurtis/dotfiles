Installation
------------


```
sh <(curl -Lf chet.cat/boot)
```


Settings
------------

The .chezmoidata directory has settings.

The file _schema.json provides default values for what should appear in `chezmoi data`.

The "chezmoidata" section should be populated programatically by files in
.chezmoidata/ that are part of the git repo and span across machines.

Machine-local user settings (not git backed) can be provided in 
~/.config/chezmoi/chezmoi.userlocal.toml

Machine-local system-wide settings (not git backed) can be provided in 
/var/lib/chezmoi/chezmoi.machlocal.toml

Clients of this schema are responsible for merging values from the top-level
and from the local section.
