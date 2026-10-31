# GoWDB-Template

A template for a game database website: the site behind
[GoW5DB](https://github.com/GearsOfWarDatabases/GoW5DB) (Gears 5), with the Gears 5 content taken out, so the
same site can be made for any game in a few minutes. Made for the
[Gears of War Databases](https://gearsofwardatabases.github.io/) (one site per game), but nothing in it is tied
to Gears.

It's a [Jekyll](https://jekyllrb.com/) site. GitHub Pages builds and hosts it for free: you edit YAML files and
push, and the site updates by itself.

## Make a site for a game

1. **Use this template** (the green button on GitHub) → name the repository, e.g. `GoW4DB`.
2. **Settings → Pages → Source: GitHub Actions.** The first deploy runs on the next push.
3. **`_config.yml`:** the `game` block (name, release date, developer, publisher), `title`, `short_name`,
   `description`, `tagline`, `credits` and `repository_url`.
4. **`_config.yml`'s `nav_groups`:** the sections your game has (see below).
5. **`_data/*.yml`:** replace the example entries with the game's. Images go in `images/<section>/<slug>.png`
   (or `.jpg`).

The site is then at `https://<owner>.github.io/<repository>/`.

## Sections

Every section is one entry in `nav_groups` (the navbar and the home page cards), one page and, usually, one data
file. Most use the `list` layout, which turns `_data/<section>.yml`'s `list` into cards or a table:

```yaml
# weapons/index.html
---
title: Weapons
layout: list
---
```

```yaml
# _data/weapons.yml
list:
  - { name: "Lancer Assault Rifle", slug: "lancer", badge: "Assault Rifle", desc: "Chainsaw bayonet. {60} rounds." }
```

The page's front matter can add:

- `group_by: faction` splits the list into headings by that field; `groups:` in the data file sets their order
  and titles.
- `columns: [{ key: health, label: Health }]` shows a table instead of cards, one column per field.
- `data: guns` reads `_data/guns.yml` instead of the folder's name.
- `images: guns` and `image_ext: jpg` say where the images are: `images/<images>/<slug>.<image_ext>`. Missing
  images just hide.
- `intro: "..."` is text under the title; the data file's `intro:` does the same.
- `coming_soon: true` (with `layout: section`) greys the section out in the menu and on the home page, with a
  "Coming soon" tip.

In a description, `{60}` is highlighted, and `[[weapons:lancer]]` links to that entry of another list page,
showing its name.

A new section: add its folder with an `index.html` like the one above, its `_data/<name>.yml`, and its line in
`nav_groups`. A page that needs more than a list (calculators, build tools, maps with markers) can be any HTML
page using `layout: default`: GoW5DB's classes, Fabricator, map and build tools are examples to copy from.

### What to start with, per game

The template starts with sections almost every Gears game has: Characters, Weapons, Enemies, Maps, Gamemodes,
plus Executions and Skins as coming soon. Some games add their own:

- **Gears of War, 2, 3, Judgment:** characters, weapons, maps, gamemodes; Horde from 2 (Horde 2.0 with
  fortifications in 3), Beast in 3, Overrun and its classes in Judgment.
- **Gears of War 4 and Gears 5:** Horde classes with skill cards, the Fabricator; Gears 5 adds Escape, marks,
  the Tour of Duty and Iron.
- **Gears Tactics:** a turn-based strategy game, no versus: classes (Support, Heavy, Sniper, Scout, Vanguard)
  with skill trees, heroes and recruits, weapon mods and armor, missions. Swap the sections for those.
- **Gears of War: E-Day:** Versus (Team Deathmatch, Conquest, Demolition, Crucible) and Horde Siege (three
  squads on one map), weapon mods, unlocks earned by playing.

## Reference screenshots

Each database can keep the screenshots its data came from in a separate repository, made from
[GoWDB-Reference-Template](https://github.com/GearsOfWarDatabases/GoWDB-Reference-Template), as its `ref/`
submodule:

```bash
git submodule add https://github.com/<owner>/<repository>-Reference.git ref
```

The site doesn't need it to build (`ref/` is excluded and the deploy doesn't fetch it). The **Reference update**
workflow moves `ref/` to that repository's newest commit every day at 04:00 UTC (or by hand: Actions → Reference
update → Run workflow) and redeploys the site when it moved; without a `ref/` submodule it does nothing.

## Running it locally

Needs Ruby (3.3, like the deploy workflow) and Bundler:

```bash
bundle install
bundle exec jekyll serve
```

Then open `http://localhost:4000`; Jekyll rebuilds when you save. On Windows, the reference repository's
`start-jekyll.bat` does the same and also fills in the revision line in the header.

## What else is in here

- **Themes:** the Theme button recolors the site; add your own in `_data/themes/` (its README explains how) and
  list them in `_config.yml`'s `theme_order`.
- **Revision line:** which commit the site was built from, in the footer on GitHub Pages builds and in the
  header's top left corner locally (`_plugins/last_commit.rb`).
- **Export this page:** the footer's button downloads the page as one HTML file that works offline.
- **Deploy:** `.github/workflows/deploy.yml` builds and publishes on every push to `main`.

## License

Copyright (C) 2026 [Ryan Turner (TheSCREWEDSoftware)](https://github.com/TheSCREWEDSoftware) and the GoW5DB
contributors.

The site's code (templates, styles, scripts and data files written for it) is free software: you can
redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your option) any later version. See
[LICENSE](LICENSE). Sites made from this template are under the same license; the games' names, images and other
content belong to their owners and are not covered by it.

## Made with

Made with the help of [Claude](https://claude.ai), Anthropic's AI assistant: written and reviewed together with it,
then tested and published by [Ryan Turner (TheSCREWEDSoftware)](https://github.com/TheSCREWEDSoftware).
