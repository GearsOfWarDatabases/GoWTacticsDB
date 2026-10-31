# Adding a site theme

Every themed color on the site - site chrome (buttons, badges, links,
borders, scrollbars), class category colors, card rarity colors, trait badge
colors, and the "codeblock" keyword system (Fabricator's cost/discount
highlights, positive/negative/neutral indicators generally) - ultimately
traces back to a set of CSS custom properties defined in `styles/main.scss`'s
`:root` block (`--site-accent`, `--theme-cat-*`, `--theme-rarity-*`,
`--theme-trait-*`, `--theme-semantic-*`). The theme picker in the header
(Theme button, after Tools) rewrites all of them at once from whichever
theme is active. This folder is the single source of truth for what themes
exist and what colors they use - the picker's swatches, and every color
value itself, are both generated from the files here. You don't need to
touch any CSS, Sass, or JS to add a theme, or to change what an
*existing* theme looks like.

## Add a new theme

1. Create a new file in this folder, e.g. `poison.yml`, and give it at least
   a name and an accent (see `default.yml` for a fully worked example with
   every optional field filled in):

   ```yaml
   name: Poison
   accent: "#7ddd3c"
   accent_dark: "#3f7f1c"
   ```

   - `name` is the label shown under the swatch in the picker.
   - `accent` is the theme's main color (buttons, links, badges, etc).
   - `accent_dark` is used for hover/active states - usually `accent` at
     roughly 40-45% lightness, i.e. noticeably darker, not just a tint.
   - The filename (minus `.yml`) becomes the theme's slug - keep it
     lowercase, no spaces. This is what's saved to the visitor's browser to
     remember their choice, so once a theme ships, don't rename its file
     without expecting existing visitors' saved choice to silently fall back
     to Default.

2. Add that slug to `theme_order` in `_includes/header.html` (search for
   `theme_order`). This folder is just an unordered pile of files as far as
   Jekyll's concerned - `theme_order` is the one place display order is
   decided. A theme file that isn't listed there won't show up in the picker
   at all.

3. Optionally add `categories:`, `rarity:`, and/or `traits:` blocks (see
   below) to customize those too. Leave any of them out and that theme just
   falls back to whatever's already compiled into the site's CSS (today's
   look) for that part - you don't have to specify everything just to add a
   theme that only changes the site accent.

4. Restart/rebuild the Jekyll dev server (data file changes aren't picked up
   by `--watch` the way template/Sass edits are) and check the new swatch in
   the Theme picker.

That's it - no Sass or JS changes needed for a normal theme.

## The full schema

Every field below is optional except `name` and `accent`/`accent_dark` - a
theme that only sets those still works fine, it just won't touch category,
rarity, or trait colors. `default.yml` carries every field filled in with
the site's current, always-shown values - copy from there rather than
re-deriving hex codes by hand.

```yaml
name: Poison
accent: "#7ddd3c"
accent_dark: "#3f7f1c"

# Class category colors (Classes/Weapons pages, .class-page--<slug> /
# .classes-section--<slug> in main.scss). `dark` is used the same way
# accent_dark is for the site accent - hover/active states, not a tint.
categories:
  assault:     { color: "#c62b0f", dark: "#6d1303" }
  tank:        { color: "#4995ff", dark: "#275ca5" }
  support:     { color: "#2fb740", dark: "#135e1d" }
  promotional: { color: "#d856d5", dark: "#7f2c7d" }

# Card rarity colors (weapon/character cards, Fabricator, etc). One hex each
# - no dark/base split, these aren't usually paired with white text the way
# accent/category colors are.
rarity:
  common: "#9e9e9e"
  uncommon: "#4adb88"
  rare: "#4a9eff"
  epic: "#b44aff"
  legendary: "#d4a017"

# Trait badges (Ammo Regen, Bleeding, Invisibility, etc, see .trait-badge in
# main.scss). `base` is optional per trait - omit it and it just reuses
# `color`. Only specify both when the badge's readable text color should be
# visibly lighter than the more saturated tone used for its background/
# border tint (see "color vs. base" below).
traits:
  default:                     { color: "#d4a017", base: "#c5a035" }
  repairing:                   { color: "#d9944f" }
  ammo-regeneration:           { color: "#8ecbff", base: "#4a9eff" }
  explosive-ammo-regeneration: { color: "#ffb066", base: "#ff8c28" }
  bleeding:                    { color: "#ff8f8f", base: "#dc3232" }
  invisibility:                { color: "#d9a8ff", base: "#b44aff" }
  marking:                     { color: "#f2c94c" }
  freeze:                      { color: "#5fd4e0" }
  shield:                      { color: "#a9bdd6" }
  summon:                      { color: "#9f8cf0" }
  melee:                       { color: "#c98a4b" }
  stim:                        { color: "#4fdba0" }

# "This makes something better/worse/neither" - the mark.kw "codeblock"
# system's kw--cheap/kw--expensive/kw--value (main.scss), the Class
# Discount/Difficulty Modifier/Set-All-Rows chips' positive/negative/neutral
# states, invalid-input flashes, danger buttons, Health Perk pip states.
# One hex each, no dark/base split. Deliberately its OWN group, not part of
# `accent` - `negative` in particular needs to stay recognizably red-ish no
# matter which theme is active, not follow the site's brand color the way
# most of the rest of this file does. See "A note on `negative`" below.
semantic:
  positive: "#7ee787"
  negative: "#f54747"
  neutral: "#d4a017"
```

All 5 shipped themes (Default/Assault/Tank/Support/Promotional) currently
carry *identical* `categories:`/`rarity:`/`traits:`/`semantic:` blocks - the
ones shown above, which match what the site has always looked like. Only
`accent`/`accent_dark` actually differ between them today. Nothing stops you
from giving any one of them (or a new theme) its own values for any of
these - the system doesn't treat Default specially, it's just the theme
that happens to ship with everything at its original value.

### A note on `negative`

`semantic.negative` didn't always exist as its own value. Before it did,
every "this is bad/expensive/invalid" spot in the CSS read `--site-accent`
directly instead - which was fine back when the site's brand color was
still literally red (see `$color-cog-red`'s own comment in
`_sass/variables.scss` for that history), but broke the moment the brand
accent moved to gold: Fabricator's "Power Drain Modifier" and other cost
INCREASES started rendering gold instead of red, same as everything else on
the site, because they'd never actually been "red" on purpose - they'd just
been *the accent color*, which used to coincidentally be red. `negative`
(and `positive`/`neutral` alongside it, for the same reason) exist
specifically so "this got worse" has a color of its own that doesn't
silently change meaning just because someone picked a different theme.
When adding new themed CSS: if what you're coloring is decorative/brand
(a button, a link, a border) reach for `--site-accent`; if it's telling the
visitor "this specific number is good/bad/neutral" reach for
`--theme-semantic-positive/negative/neutral` instead, even if, coincidentally,
they render the same color today.

### `color` vs. `base` on trait entries

Most traits use the exact same color for their badge text as for their
background/border tint - for those, just set `color` and skip `base`
entirely. A handful (the `default` no-modifier state, `ammo-regeneration`,
`explosive-ammo-regeneration`, `bleeding`, `invisibility`) use a visibly
*lighter* `color` for legible text against a `base` that's more saturated
and used only for the translucent fill/border - set both if you want that
same two-tone effect on a trait you're customizing.

## Adding a brand new category, rarity tier, or trait (not just a theme)

Everything above is about giving an *existing* category/rarity tier/trait a
new color per theme. Introducing a genuinely new one - a 5th class category,
a 6th rarity tier, a 13th trait type - is a different, bigger change: the
key you add to a theme's YAML only has an effect where some CSS rule already
reads the matching `--theme-<group>-<key>...` custom property (see "How
this actually works" below), so a new key on its own does nothing yet. That
still needs an actual CSS hook added in `styles/main.scss` (e.g. a new
`.class-page--<slug>` block, or a new `&--<key>` trait modifier) before any
theme's value for it will show up anywhere. Once that hook exists, add the
new key to every shipped theme's YAML (matching whatever the feature's
"default" color should be) the same way the existing keys are duplicated
across all 5 today.

## Sharing/linking a theme

Every theme is also reachable via a `?theme=<slug>` URL query param - e.g.
`/classes/?theme=tank` loads that page with the Tank theme applied, no click
needed. Selecting a theme through the picker updates the current page's URL
to match (so copying the address bar after picking one gives you a link back
to it), and that link works for anyone, not just the browser that picked it.
This falls out of the same `theme_order`/slug system above automatically -
there's nothing extra to wire up when adding a theme.

## Picking a color

Buttons and badges routinely place solid white text on top of `accent` (and
category `color`), so it needs to stay legible at that weight - roughly a
4.5:1 contrast ratio against white, similar to how dark/saturated the
existing theme colors are. A bright, light color (pale yellow, light pink)
will look washed out or fail to read under white text. When in doubt, check
it against white text on a button in the browser before committing to it,
the same way Default (`#8c6d12`) and the four category-matched themes
(Assault/Tank/Support/Promotional) were chosen.

The four non-Default themes intentionally reuse the exact hex values already
used for their matching class category color - if you're theming a site
accent after an existing category, pull its values from that theme's own
`categories:` block rather than re-deriving new ones, so the site accent and
that category's page styling agree.

Also steer clear of `$color-guides-nav` (teal, `#2dbfae`) and
`$color-tools-nav` (slate, `#93a1b8`) in `_sass/variables.scss` - the Guides
and Tools nav buttons next to the Theme button. Those two were deliberately
picked to sit in hue gaps outside every existing theme's `accent` so they
never end up the same color as whichever theme is currently active (the
Theme button itself always shows the live `--site-accent`, right next to
them) - a new theme's `accent` landing on one of those hues would
reintroduce that exact collision.

## How this actually works (for anyone touching the system itself)

- `_includes/header.html` loops over `theme_order`, looks each slug up in
  `site.data.themes` (Jekyll auto-loads every file in this folder into that
  hash, keyed by filename), and renders one `.theme-picker__swatch` button
  per theme with that theme's *entire* data as one JSON blob in a single
  `data-theme` attribute (`{{ theme | jsonify | escape }}`) - not individual
  `data-theme-accent`/etc attributes. That's deliberate: it means adding a
  new field to the schema (a new category, a new rarity tier, extending
  `traits:`, or something not listed above at all) never needs a matching
  markup change here.
- `#site-theme-switcher` in `_includes/footer.html` parses that JSON once
  per swatch on load, then applies it via `applyTheme()` - a function that
  writes `--site-accent`/`--site-accent-dark` directly, has one small
  explicit block each for the two "structured" groups (`categories`: color +
  dark; `traits`: color + base), and loops a `['rarity', 'semantic']` array
  for the "flat" groups (a plain `{ key: "#hex" }` map, one custom property
  per entry). None of these hardcode the four category names, five rarity
  tiers, three semantic keys, or twelve trait keys anywhere, so a theme
  adding a new key under an existing group (once that group has a CSS hook
  for it, see above) works with no JS change. Adding an entirely new *flat*
  group only means adding its name to that `['rarity', 'semantic']` array;
  a new *structured* group (something needing more than one value per
  entry, like `categories`/`traits`) needs its own small block the same
  shape as those two.
- Hovering/focusing a swatch calls `applyTheme()` for a live preview with no
  persistence; leaving it reverts to whichever theme is actually selected.
  Clicking a swatch does the same but also saves the slug to `localStorage`
  (key `<short_name>-theme`, from `_config.yml`) and reflects it into the URL (see "Sharing/linking a
  theme" above), and marks the swatch `.is-selected` so hovering elsewhere
  and back reverts to it instead of Default. On every page load, the script
  restores whatever slug was last saved (falling back to the first swatch/
  Default if none, or an unrecognized one) before the visitor sees anything.
  A `?theme=<slug>` URL param, when present and valid, wins over the saved
  value and is treated as a real selection too (persists to localStorage,
  updates the URL).
- Everywhere in the CSS (`_sass/home.scss`, `styles/main.scss`) that needs a
  variant of a themed color - a lighter hover state, a translucent
  background, etc. - uses the CSS `color-mix()` function against the
  relevant `var(--theme-...)`, e.g.
  `color-mix(in srgb, var(--site-accent) 15%, transparent)` for a
  translucent fill, or `color-mix(in srgb, var(--theme-rarity-epic), white
  15%)` to lighten. This is deliberate: Sass's own `rgba()`/`lighten()`/
  `darken()` only run once, at compile time, baking in whatever the SCSS
  variable was at build time - they can't react to a runtime theme change.
  `color-mix()` can, because it's real CSS evaluated by the browser on every
  repaint. If you're adding new themed CSS elsewhere in the codebase, use
  `color-mix()` against the matching `--theme-...` custom property the same
  way, not a Sass color function against a `$color-...` variable.
- Every one of those custom properties still has a real compile-time default
  too (in `_sass/variables.scss`, fed into `styles/main.scss`'s `:root`
  block) - that's what renders before the switcher script runs on first
  load, and what a visitor with JS disabled sees permanently. Keep those in
  sync with `default.yml`'s values if you ever change one, since they're
  meant to be the same "what the site has always looked like" baseline.

## Scrollbars

Every themed scrollbar on the site (the sitewide default in `styles/main.scss`,
plus the per-panel ones in `_sass/home.scss` - class lists, the map
calibrator's viewport, its point list, etc) already reads
`color-mix(in srgb, var(--site-accent) 50%, transparent)` for its thumb
color, same as everything else tracking the site accent - there's no
separate "scrollbar" field in the schema because there was never a second
color to give one. Picking a theme already recolors every scrollbar on
every page along with everything else `--site-accent` touches. If you add a
new scrolling element anywhere, copy the `scrollbar-width`/`scrollbar-color`
pair from one of the existing ones (search `scrollbar-color` in either file)
rather than hardcoding a color, so it stays consistent.

## Removing a theme

Delete its `.yml` file and remove its slug from `theme_order` in
`header.html`. Any visitor who had it selected falls back to Default (the
switcher's "unrecognized slug" fallback above) next time they load the site -
nothing else needs to change.
