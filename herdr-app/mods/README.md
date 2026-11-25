# Personal Herdr mods

Better Changes 2.5.0, Better Files 1.5.1, Better Icons 1.0.0 and Branch PR 2.3.0 come from [munza/herdr-mods](https://github.com/munza/herdr-mods/tree/860626068cb7e32a1db96b2f66baadc271d5667a). Upstream attribution is preserved in LICENSE-herdr-mods and NOTICE-herdr-mods; Better Icons also includes its Material Icon Theme license.

Local changes: Better Files adds a Collapse all folders button beside Open folder. dotfiles-tabs is a clone of the shipped Tabs 0.1.16 mod, with a PRs button. The personal dotfiles-reload layout uses these panels. Files and Changes visibility follows the Herdr welcome screen preferences.

Branch PR requires an authenticated GitHub CLI (`gh auth login`). Its included `bin/herdr-pr` is a universal macOS executable for Intel and Apple Silicon. To rebuild for another platform, check out the upstream commit above and run `go -C branch-pr/helper run ./install`; the upstream installer builds the helper and installs the Branch PR mod into the Herdr configuration folder.

The personal `numbered-spaces` sidebar shows listening TCP ports and their process names below each space's branch, for example `node:3000`. It uses `ps` and `lsof` on each connected machine to associate listeners with terminal process trees, including child core terminals, rather than matching by folder. Ports refresh every five seconds while the window is active; closed listeners and unavailable machines lose their badges. Remote machines need these commands installed. The compact sidebar lists ports in the space tooltip. Run its tests with `node --test herdr-app/mods/numbered-spaces/ports_test.cjs`.
