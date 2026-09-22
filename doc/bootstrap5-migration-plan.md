# Bootstrap 5.0.2 Migration Plan (Targeted)

## Goal

Migrate from Bootstrap 3.3.7 to Bootstrap 5.0.2 in safe, reviewable steps with minimal regressions.

## Scope Snapshot (from audit)

- BS3 class hits: **1309**
- BS3 data API hits (`data-toggle`, etc.): **55**
- BS3 JS plugin API hits (`.modal()`, etc.): **8**
- Largest hotspot: `grails-app/views/transcribe/templateViews/**`
- Global-risk files: `grails-app/views/layouts/**`, `grails-app/assets/scss/bootstrap/**`

---

## Phase 1 — Asset + Layout Foundation

**Objective:** Load BS5 correctly and prevent global breakage before page-level migrations.

### Tasks

- [X] Replace Bootstrap 3 assets in `grails-app/assets/lib/compile/bootstrap*` with Bootstrap 5.0.2 assets.
- [X] Ensure Popper is included (Bootstrap bundle JS or separate Popper).
- [X] Update style/script includes in:
    - [X] `grails-app/views/layouts/digivol-main.gsp`
    - [X] `grails-app/views/layouts/digivol-task.gsp`
    - [X] `grails-app/views/layouts/digivol-projectSettings.gsp`
    - [X] `grails-app/views/layouts/_condensedNav.gsp`
- [X] Keep jQuery only for legacy app scripts; do not rely on it for Bootstrap components.
- [X] Add temporary bridge stylesheet (small, utility-only).

### Done when

- [X] No Bootstrap 3 JS include remains in layout files.
- [X] App shell renders without fatal JS errors.
- [X] Navbar collapse works on mobile in main layouts.

---

## Phase 2 — Global Markup API Migration

**Objective:** Migrate shared Bootstrap attributes/classes used across layouts and common partials.

### Tasks

- [X] Convert data attrs in layouts/common:
    - [X] `data-toggle` -> `data-bs-toggle`
    - [X] `data-target` -> `data-bs-target`
    - [X] `data-dismiss` -> `data-bs-dismiss`
- [X] Update close button markup in alerts/modals.
- [X] Replace utility classes where encountered:
    - [X] `pull-left/right` -> `float-start/end`
    - [X] `text-left/right` -> `text-start/end`
    - [X] `img-responsive` -> `img-fluid`

### Done when

- [X] No `data-toggle|data-target|data-dismiss` remain in `grails-app/views/layouts/**`.
- [X] Core navigation and global dismissible UI function in BS5.

---

## Phase 3 — High-Impact Page Migrations

**Objective:** Migrate the highest-hit individual pages before bulk folders.

### Priority files

- [X] `grails-app/views/stats/index.gsp`
- [X] `grails-app/views/frontPage/edit.gsp`
- [X] `grails-app/views/template/edit.gsp`

### Common replacements

- [X] `panel*` -> `card*`
- [X] `btn-default` -> `btn-secondary`
- [X] form labels/help classes to BS5 equivalents
- [X] old grid/offset utility cleanup

### Done when

- [X] Each page renders and key interactions work.
- [X] No BS3-only component classes remain on migrated pages.

---

## Phase 4 — Transcribe Domain Migration (Largest Block)

**Objective:** Complete the biggest hotspot end-to-end.

### Targets

- [X] `grails-app/views/transcribe/templateViews/**`
- [X] `grails-app/views/transcribe/task.gsp`
- [X] `grails-app/views/transcribe/_imageSelectWidget.gsp`
- [X] `grails-app/assets/javascripts/transcribe/**`

### Tasks

- [X] Migrate tabs/collapse/dropdown/modal markup + data attrs.
- [X] Replace BS3 jQuery plugin calls with BS5 JS API where needed.
- [ ] Validate task flows (open, save, navigate, modal actions).

### Done when

- [ ] No BS3 data attrs remain in transcribe views.
- [ ] No `.modal()/.tab()/.collapse()/.dropdown()` BS3 usage remains in transcribe JS.
- [ ] Primary transcribe workflow passes manual smoke test.

---

## Phase 5 — Remaining Data-API Hotspots

**Objective:** Finish pages still using old Bootstrap data APIs.

### Targets

- [X] `grails-app/views/user/notebook.gsp`
- [X] `grails-app/views/picklist/manage.gsp`
- [X] `grails-app/views/institutionAdmin/index.gsp`
- [X] `grails-app/views/institutionAdmin/applications.gsp`
- [X] `grails-app/views/task/manageUploads.gsp`
- [X] `grails-app/views/admin/manageUserRoles.gsp`
- [X] Other files reported by grep

### Done when

- [X] No remaining old Bootstrap data attrs in views/taglibs.

---

## Phase 6 — Cleanup + Bridge Removal

**Objective:** Remove temporary compatibility code and finalize.

### Tasks

- [X] Remove temporary bridge CSS.
- [X] Remove dead BS3 overrides from:
    - [X] `grails-app/assets/scss/bootstrap/**`
    - [X] `grails-app/assets/scss/modules/**`
    - [X] `grails-app/assets/stylesheets/*.css`
- [X] Final grep sweep and fix residuals.

### Done when

- [X] No BS3 class/API patterns remain.
- [X] UI regression checklist complete.

---

## Regression Checklist (Run each phase)

- [X] Main nav collapse/expand on mobile
- [X] Modals open/close/backdrop behavior
- [X] Tabs switch correctly
- [X] Dropdowns and collapse toggles work
- [X] Key create/edit forms still submit and validate
- [X] Top user workflow per affected area works

---

## Phase 7

**Objective:** Migrate defunct bootstrap plugins

### Tasks

- [X] Bootstrap Notify
- [X] Bootstrap colorpicker
- [X] Bootstrap datepicker
- [X] Bootstrap fileinput
- [X] Bootstrap select
- [X] Bootstrap switch
- [X] jQuery UI
- [X] qTip

---

## Phase 8

**Objective:** Fix UI styles

### Prompt for AI assistance

#### Task

Standardise <AREA> across the app as part of Phase 8 of doc/bootstrap5-migration-plan.md.

#### Context you must load first

- doc/bootstrap5-migration-plan.md — especially the "Button conventions (established Phase 8)" section and the Tracking
  Log.
- .github/copilot-instructions.md — style guardrails. Follow the conventions already established there. If this task
  needs a new convention, propose it before writing code.

#### Step 1 — Audit (read-only, no edits)

Grep the codebase and report, before changing anything:

- every file/line touching <AREA>, grouped by pattern
- which SCSS file currently owns each rule, and load order
- dead / BS2 / BS3 / 2015-design-comp leftovers
- anything that is a bug rather than a style inconsistency
- anything out of scope that you noticed (a11y, semantics, duplication)
  Give me counts, not just examples, so I can judge the size.

#### Step 2 — Propose

Based on the audit, propose:

- the convention table (what class means what, when to use which)
- a numbered, independently reviewable step list, ordered so that each step leaves the app working
- explicit "removed — do not reintroduce" list
- anything you recommend deferring, and why Stop. Wait for my sign-off before editing.

#### Step 3 — Implement

Work one numbered step at a time. After each step:

- list files changed and why
- flag anything you found mid-step that changes the plan Don't batch unrelated fixes into a step. Don't add abstraction,
  configurability or error handling I didn't ask for.

#### Step 4 — Document

When the task is done, update doc/bootstrap5-migration-plan.md:

- tick the task checkbox
- add/extend the conventions section (single source of truth, no duplication of what's already documented)
- add a dated Tracking Log entry covering: what was standardised, what was retired, bugs fixed while in scope, and any
  correction to a previous entry
- add new unchecked follow-up items for everything found but deliberately not done, each with enough detail (file +
  line + symptom) to action cold
- for follow-ups needing a judgement call, include a "Prompt:" line stating the decision to be made

#### Constraints

- Report findings, don't silently fix out-of-scope things — add them as follow-ups instead.
- Call out speculative generality in anything you or I propose.
- If a grep looks truncated, say so and re-run narrower; don't assume.

### Tasks

- [X] Standardise button styles
- [X] Standardise font sizes & breadcrumbs
- [X] Standardise form styles (inc bvp checkboxes)
- [X] Standardise search form styles
  - [X] Volunteer facing search form should mirror navbar search field
  - [X] Admin search form field should mirror task/list
- [ ] Fix pagination styles
- [ ] Fix date picker styles
- [ ] Fix file upload browse button style
- [ ] Standardise table styles
- [ ] Standardise modal styles (BS5 vs Bootbox)
- [ ] Navbar
    - [ ] bg colour
    - [ ] Condensed nav doesn't line up with main nav
- [ ] Fix aria-hidden warnings (if sticking with bootbox - see specimenLabelTranscribe)
- [ ] Standardise alert styles
- [ ] Questionaire template is broken (BS5 requires data-bs-target / data-bs-slide-to)
- [ ] Project index page with info cards
- [X] Help text icons
- [ ] Tag styles are broken (label, label- *, pill, pill-*, badge, badge-*)
- [ ] Dropdown menu styles (inc double caret)
- [ ] Keyboard inaccessible buttons/a11y
    - [ ] `fieldHelp` uses `<a href="#">` + `tabindex="-1"` — tooltip is keyboard-unreachable. Should be
      `<button type="button">`.
    - [ ] `newsItem/manage.gsp` 119 — `<span class="btn">` as an edit control.
    - [ ] `.btn { outline: none }` removes the focus ring app-wide (WCAG 2.4.7)
      — replace with `:focus-visible` (see Step 5-iii).
- [ ] Index page
- [ ] Stats page
- [ ] Transcribe pages
- [ ] Institution/Project/Custom landing page lists
- [ ] Institution/Project admin pages
- [ ] Template edit collapsable list
- [ ] notebook-2 design system alignment (forum, user/show, user/achievements, tutorials, newsItem/index)
    - These pages load `forum-2.scss` / `notebook-2.scss` / `tutorials-2.scss` /
      `news.scss` **in addition to** digivol.css, as a last-loading overlay.
    - [ ] Derive `$digivol-orange` from `base/_variables.scss` `$brand-color`; remove the two hard-coded `#d5502a` in
      `_global.scss` (110, 120).
    - [ ] "Create New Topic" uses `.pill--bg-new-post` (a badge component) as a button — switch to
      `.forum-post-button` + `display: inline-block`.
    - [ ] Remove unscoped `.btn { border-radius: 4px !important }`
      (`_newsItems.scss` 170).
    - [ ] Design decision: should `.forum-post-button` (black / orange hover)
      align with `btn-primary`? Take to the colour discussion.
    - Note: `_global.scss` restyles bare `table`/`th`/`td` — relevant to the
      "Standardise table styles" task. `.pill--*` is relevant to "Tag styles".
- [ ] Admin pages
- [ ] Fix tooltips on wildlife spotter config (create/destroy on maximise/minimise)
- [ ] `TranscribeTagLib` drops `cssClass` for checkbox fields. Every other branch emits `"$cssClass form-control"`; the
  checkbox branch emits only a class literal, so `validate[required]` is lost — **mandatory checkbox fields are not
  validated**. Behaviour bug, not styling.
  - Prompt: "Confirm whether mandatory checkbox fields were ever meant to be enforced, then restore `cssClass` on the
    checkbox branch and cover it."
- [ ] Required-field marking is inconsistent. Only a few `.form-group`s carry
  `required` (e.g. `achievementDescription/_form.gsp` 2, 12, 22); many fields set the HTML `required` attribute with no
  class and show no asterisk; others hard-code `*` in the label text (`newsItem/create.gsp` 57, 64, 72, 80), which would
  double up if the class were added.
  - Prompt: "Pick one source of truth — derive the asterisk from the `required`
    attribute, or apply `.form-group.required` everywhere — then strip the hard-coded asterisks. Confirm the
    requirement is announced to screen readers, since a CSS `:after` asterisk is not."
- [ ] Custom landing page admin
- [ ] Update edit action icons from fa-edit to fa-pencil
- [ ] Remove 2015 static design and dead css classes
- [ ] BS2 grid classes still live (`row-fluid`, `span1`–`span12`) — locality/ collectionEvent searchFragment, picklist
  images/wildcount/edit, user/notebookMainFragment, layouts/transcribeTool. Layouts currently collapse to full-width
  stacked divs.
- [ ] BS2 form scaffolding (`form-horizontal`, `control-group`, `controls`)
  throughout fragments.
- [ ] Sweep remaining `hide` → `d-none` outside the project filter blocks.
- [ ] angular-ui-bootstrap 1.3.3 datepicker/timepicker emit `btn-default` + glyphicons — renders unstyled. Legacy
  library, maintenance only.
- [ ] `admin/tools.gsp` 68–72 — buttons in a `<g:form>` with no `type="button"`, default to submit.
- [ ] Align notebook-2 heading sizes with the global scale
    - `notebook-2/_global.scss` 12–30 sets `h1: 1.875rem` (→ `2.25rem` at
      `$screen-md`) and `h2: 1.5rem` (→ `1.875rem`). `notebook-2/_newsItems.scss`
      176 sets `.a-feature.simple-header h1: 2rem`. These load after digivol.css and win on forum, user/show,
      user/achievements, tutorials and newsItem/index, so those pages ignore the global scale in
      `modules/_typography.scss`.
    - Prompt: "Align the notebook-2 heading rules with the global heading scale in scss/modules/_typography.scss
      (h1 = $font-size-2xl 26px, h2 = $font-size-xl 22px). Decide whether the responsive step-up
      at $screen-md should be kept for all pages or dropped. Note notebook-2 has its own token scale ($
      text-xs…$text-6xl) in _variables-and-mixins.scss — reconcile with the
      $font-size-* tokens in base/_variables.scss, ideally by deriving one from the other so there is a single source of
      truth."
- [ ] Rename eyebrow styles so they stop looking like heading overrides
    - `h2.heading`, `.pre-header` (`modules/_components.scss` 382–394) and
      `h2.body-heading` (396–403) are uppercase letter-spaced section labels, not heading sizes. `.modal h5` (884)
      includes the same `h2-heading` mixin.
    - Prompt: "Rename the h2-heading mixin and its consumers to an `.eyebrow`
      component so they are not mistaken for heading size overrides. Update call sites in modules/_components.scss,
      modules/_sections.scss, notebook-2/_newsItems.scss 218 and the GSPs using class='heading' /
      'pre-header' / 'body-heading'. Behaviour must not change."
- [ ] Heading semantics / document outline (fold into "Keyboard inaccessible buttons/a11y" or track separately)
    - `template/audioTemplateConfig.gsp` 47 and 154, and
      `template/wildlifeTemplateConfig.gsp` 42 and 160, each render two `<h1>`
      elements on one page; the second ("Animals") is a sub-section and should be
      `<h2>`.
    - `<h4>Step 1</h4>`, `<h4>EITHER</h4>`, `<h4>OR</h4>` in the specimen/label transcribe templates are layout labels,
      not headings, and create empty outline levels.
    - Prompt: "Fix the heading document outline: one h1 per page, no skipped levels, and no headings used purely for
      visual weight. Convert the transcribe step labels to non-heading elements without changing the grid layout."
- [ ] `.digivol-logo { font-size: 0.5rem }` (`layouts/_nav.scss` 26)
    - The element's only child is a block-level `<img>` at `width: 100%`, so this declaration appears to be dead or a
      whitespace-collapse hack.
    - Prompt: "Determine whether .digivol-logo's font-size is load-bearing; remove it if not. Check the navbar brand at
      all breakpoints."
- [X] `project/index.gsp` 105 — `<a disabled="disabled">` is invalid; `disabled`
  is not an anchor attribute. Needs `class="disabled"` + `aria-disabled="true"`
    + `tabindex="-1"`. (Fold into the a11y item.)
- [X] `project/index.gsp` 76/82/94 — tutorial panel `<h4>` headings dropped from 24px to 16px with the new scale.
  Confirm they still read as headings; if not, adjust `font-weight` rather than reintroducing a size override.
- [ ] Breadcrumbs - truncate long project names, add ellipsis in middle of breadcrumb trail so we see the start and end
  of the name, and add `title` attribute for full name on hover.
- [ ] Field-level validation feedback is absent. `hasErrors(bean:…, 'has-error')`
  appears throughout the GSPs but `has-error` is BS3 and has zero CSS anywhere;
  `help-block` has zero occurrences. Invalid fields render no visual feedback.
- Prompt: "Migrate `has-error` to BS5 `is-invalid` + `invalid-feedback`. Decide whether the message comes from the
  Grails `hasErrors`/`fieldError`
  server-side path, client-side constraint validation, or both."
- [ ] `form-control` on `<select>` should be `form-select` (~40+ sites). Includes `frontPage/edit.gsp` 230–232, where
  `$(this).attr('class', 'form-control')` also **clobbers** every existing class on `.grails-date select`.
- [ ] `report/userReport.gsp` 68/76/86 and `report/projectSummary.gsp` 24 put
  `input-group` and `col-*` on the same element (latent layout bug), and use BS3 `col-sm-offset-3` instead of
  `offset-sm-3` (currently a no-op).
- [ ] `newsItem/create.gsp` 24 loads bootstrap-datepicker CSS from a public CDN — external runtime dependency and
  supply-chain exposure on an admin page. Vendor it with the other assets.
- [X] `TranscribeTagLib.getWidgetHtml` has 15 widget branches and no tests. It is private and depends on `Task`,
  `TemplateField`, `field.template.viewParams`
  and GORM statics (`ValidationRule`, `Picklist`), so a unit test currently costs more than it's worth.
    - Prompt: "Decide whether to separate widget rendering from GORM lookups to make it testable, or accept it as
      untested legacy."
- [ ] `.btn-file input[type=file]` (`digivol-custom.css` 30–44) is `opacity: 0`
  **and** `outline: none`, and the visible `.btn-file` has no `:focus-within`
  style — the file picker gives keyboard users no focus indicator.
    - Prompt: "Add a `:focus-within` ring to `.btn-file` without un-hiding the native input." (Fold into the file-upload
      and a11y items.)
- [ ] Review the font-size overrides in `digivol-custom.css`: live off-scale values at 89 (`75%`), 101 (`12px`), 126
  (`larger`), 160 (`12px`), 243 (`16px`), 253 (`18px`), 315 (`inherit`). The file loads after the SCSS, so these beat
  the `$font-size-*` scale. Line 169 is a commented-out
  `.admin h1 { font-size: 2.5em !important }` — dead, delete. Line 36 (`100px`)
  is the `.btn-file` glyph hack and is probably legitimate.
    - Prompt: "Tokenise or delete each font-size in digivol-custom.css against the `$font-size-*` scale. Then decide
      whether digivol-custom.css should exist at all, or be folded into the SCSS pipeline so load order stops being a
      factor — it now has no form rules left."
- [ ] Dead BS2/BS3 classes found during the form sweep: `.well`
  (`user/edit.gsp` 108) and `.form` (`template/create.gsp` 30). Neither has any CSS. Fold into the BS2 grid/scaffolding
  sweep.
- [ ] Design decision: should required-field labels be bold? A
  `.form-control.required .form-label { font-weight: bold }` rule existed but had never matched, so it was deleted
  rather than silently activated.
- [ ] `frontPage/edit.gsp` — "Find an expedition" doesn't fill in the select. The handler (222–228) calls
  `bvp.selectProjectId()` then
  `$("#projectOfTheDay").val(projectId)`, but the select is populated by
  `<cl:projectSelectGrouped archiveFlag="${false}" inactiveFlag="${false}"/>`
  (49). If the chosen expedition is archived or inactive there is no matching
  `<option>`, so jQuery's `.val()` silently no-ops and the previous value stays.
    - Prompt: "Decide whether the finder should be restricted to the same active/non-archived set as the select, or
      whether picking an archived expedition should inject the option. Add visible feedback when the selection can't be
      applied."
- [ ] `task/list.gsp` 60 — `style="height:32px"` on `<select class="form-control statusFilter">`.
  The last survivor of the `height: 25px` era; the same select appears without it
  in `task/adminList.gsp` 119, `newsItem/manage.gsp` 33, `tutorials/manage.gsp` 94,
  `task/manageUploads.gsp` 48 and `project/manage.gsp` 110. Fold into the
  `form-control` → `form-select` sweep.
- [ ] `picklist/show.gsp` 11 — `location.href = "?q=" + query` with no
  `encodeURIComponent`. Any `&`, `#` or `+` in the search term corrupts the query
  string. Every other `doSearch()` in the app encodes. Behaviour bug.
- [ ] Volunteer search forms have no `action` and no hidden inputs, so they are
  still JS-only and the `<form>` is decorative on submit.
  - Prompt: "Decide whether volunteer search should work without JS. If so, give
    each form a real GET action plus hidden inputs for `mode`/`statusFilter`/
    `activeFilter`/`sort`/`order` and delete the URL-building JS."
- [ ] `project/list.gsp`, `institution/list.gsp` and `institution/index.gsp` do
  not echo `params.q` back into the search input — the term appears only as a
  removable `.currentFilter` tag. `newsItem/manage`, `tutorials/manage`,
  `task/manageUploads` and `picklist/show` do echo it. Inconsistent.
  - Prompt: "Pick one: echo the term in the field, or show it as a removable tag."
- [ ] `modules/_search.scss` — the `$screen-md`–`$screen-lg` media query still
  carries four `!important` declarations inherited from `_nav.scss`. With the
  float now scoped to `.body`, check whether any are still needed.
- [ ] `.card-filter { margin-top: -12px }` (`modules/_components.scss` 349) exists
  to compensate for the floated, fixed-width search pill. Re-check whether it is
  still required now that the admin pages no longer use that wrapper.


---

### Design conventions (established Phase 8)

#### Buttons

Bootstrap 5.0.2 is vendored as **precompiled CSS** (`digivol.css` requires
`compile/bootstrap-5.0.2/css/bootstrap.css`). Bootstrap's Sass variables are therefore not configurable, and
`@extend .btn-sm` will not work. All button theming is an override layer in `scss/modules/_buttons.scss`, which loads
after bootstrap.css. Colour tokens live in `scss/base/_variables.scss`.

Note `scss/bootstrap/_variables.scss` is a Bootstrap 3 leftover that feeds only our own SCSS. Do not reference it in new
code (`$brand-primary` there is the old BS3 blue). It is slated for deletion.

**Weight — one filled button per cluster:**

| Class                   | Meaning                                                              |
|-------------------------|----------------------------------------------------------------------|
| `btn-primary`           | The page's single main action. Create / Add / Save / Submit          |
| `btn-secondary`         | Affirmative action of a self-contained sub-form (e.g. filter Apply)  |
| `btn-outline-secondary` | Neutral, dismissive, repeated or secondary. The default              |
| `btn-success`           | Confirming or approving an item. **Not** "create"                    |
| `btn-warning`           | Reversible but consequential state change (reset status, clear data) |
| `btn-danger`            | Destructive and irreversible. Delete / Destroy                       |
| `btn-outline-light`     | Hero CTAs over a background image                                    |
| `btn-link`              | Inline controls with no button affordance                            |

Permission level is not a colour — admin-only actions use normal weights.

**Size:**

- `btn-sm` — dense containers: table rows, filter toolbars, card headers,
  `btn-group` pills, in-page toolbars.
- default — page-level actions, form submit clusters, modal footers.
- `btn-lg` — hero CTAs only.

**Removed — do not reintroduce:**
`btn-xs`, `btn-small`, `btn-mini`, `btn-default` (BS2/BS3 sizes and variants),
`btn-hollow`, `btn-load`, `btn-complete`, `btn-next` (2015 design comp),
`icon-*` / `icon-white` (BS2 glyphs — use `fa fa-*`), `bs3`, `btn-admin`,
`hide` (BS3 — use `d-none`).

**Retained custom classes:**

- `.btn-circle` — step-wizard indicator, always with `btn-outline-secondary`.
- `.btn-icon-svg` — sizing for inline SVG icons inside buttons.
- `.btn-file` — file-picker positioning hack, not a colour.

Field help icons are styled solely by `a.fieldHelp` in
`scss/modules/_components.scss`. Taglibs emit `class:'fieldHelp'` only — the class is also the JS tooltip binding hook
(`bvp-common.js`, `bindTooltips`).

#### Typography:

Base size is set once in `scss/base/_variables.scss` (`$font-size-body`) and applied in `scss/modules/_typography.scss`.
`html { font-size: 100% }` keeps the app responsive to the user's browser font-size setting (WCAG 1.4.4), so all sizes
must be `rem` via the `$font-size-*` scale — never hard-coded `px`.

Exception: `font-size` used to size an icon glyph rather than text may stay in
`px`. Comment these so they aren't mistakenly tokenised.

Do not reference `$font-size-base` / `$font-size-small` / `$font-family-base` — those come from the BS3 leftover
`scss/bootstrap/_variables.scss`, which has no remaining typography consumers and is slated for deletion.

**Headings:**

`h1`–`h6` are sized once in `scss/modules/_typography.scss` from the
`$font-size-*` scale (h1 26px … h6 12px, against a 14px body). Do not set heading `font-size` per container — that is
what caused `h3` to render smaller than `h2` inside `.a-feature`.

Display/hero headings opt in explicitly: `.a-feature.home h1` and
`.a-feature.wildlifespotter h1` use `$font-size-3xl`. Everything else uses the global scale.

`h2.heading`, `.pre-header`, `h2.body-heading` and `.modal h5` (via the
`h2-heading` mixin) are *eyebrow* styles — uppercase, letter-spaced, 14–16px. They are not heading sizes. Leave them
alone.

`font-size` used to size an icon glyph rather than text may stay in `px`:
`.icon-size` (87px) and `.digivol-logo` (0.5rem) are the only such exceptions.

#### Forms:

All form styling lives in `scss/modules/_forms.scss`, imported from `main.scss`
after `modules/components`. `digivol-custom.css` no longer contains any form rules — do not add them back there, it
loads after the SCSS and silently wins.

| Class                                                  | Meaning                                                            |
|--------------------------------------------------------|--------------------------------------------------------------------|
| `form-label`                                           | Every label. Always paired with `for` + control `id`               |
| `form-control`                                         | Text-like `<input>` and `<textarea>` only                          |
| `form-select`                                          | `<select>`                                                         |
| `form-check` + `form-check-input` + `form-check-label` | Checkbox / radio                                                   |
| `form-check form-switch form-switch-lg`                | Boolean settings toggles                                           |
| `form-group`                                           | Local component (BS5 removed it): one label + control + help/error |
| `form-condensed`                                       | Wrapper for dense forms (transcribe widgets)                       |
| `form-text`                                            | Help text, referenced by `aria-describedby`                        |
| `is-invalid` + `invalid-feedback`                      | Field-level validation                                             |

Never set a fixed `height` on `.form-control` — it sizes from `padding` +
`line-height`. A fixed 25px height was the root cause of seven separate compensating patches across four files.

`.form-condensed` is the only sanctioned way to tighten form density. Do not override `.form-control` in a page
`<style>` block or inline `style=`.

Where a label sits in its own `col-*`, use a standalone `.form-check-input`
without the `.form-check` wrapper — the wrapper's `padding-left` is for an adjacent label.

Focus rings are themed on `$focus-ring-color` (= `$link-color`) so form controls match `a:focus-visible` in
`base/_base.scss`. Never `outline: none`
or `outline: 0` on a focusable control (WCAG 2.4.7).

**Removed — do not reintroduce:**
`form-horizontal`, `control-group`, `controls`, `control-label`,
`input-xlarge`/`-large`/`-medium`/`-small`, `uneditable-input` (BS2);
`has-error`, `help-block` (BS3 — use `is-invalid` / `invalid-feedback` /
`form-text`); `form-control` on a checkbox, radio or file input; fixed
`height` on `.form-control`; `select[type="text"]` (matches nothing).

#### Search fields

Owned by `scss/modules/_search.scss` (moved out of `layouts/_nav.scss` — the component is body content, not navigation).

| Context | Markup |
|---|---|
| Navbar and volunteer-facing page search | `.custom-search-input[.body]` > `<form role="search">` > `.input-group` > `input[type=search].form-control` + `<button class="btn" type="submit">` |
| Admin search in a card/filter toolbar | plain `.input-group` > `.form-control` + `<button class="btn btn-sm btn-primary" type="button">` |
| Admin filter field with an explicit Apply button | bare `.form-control`, no `input-group`, no icon button |
| Search inside a modal or tool panel | `.custom-search-input.in-modal` |

Every search control needs a `visually-hidden` `<label for>`; a placeholder is not a label. Icon-only buttons need
`aria-hidden="true"` on the `<i>` and a
`visually-hidden` text label.

**The label must sit outside `.input-group`.** Bootstrap 5 derives input-group border radii and the -1px overlap margin
from `:first-child` / `:last-child`
(`bootstrap.css` 2713–2727). Any extra element inside the group — even a zero-layout `visually-hidden` label — shifts
those selectors and squares off the control. Never put anything in an `.input-group` except the controls themselves.

The pill's focus ring is drawn on the wrapper via `:focus-within`; the inner input suppresses its own `box-shadow`. This
is the one sanctioned place where a
`.form-control` focus shadow is removed, because the wrapper draws it instead.

`.custom-search-input` is a poor name (it is neither custom nor nav). Renaming touches 11 GSPs for no user-visible
gain — do it when the 2015 static design is deleted.

**Removed — do not reintroduce:** `height` on `.custom-search-input input`;
`border-radius … !important` on the wrapper; `class="btn"` with no variant; icon-only search buttons with no accessible
name; `.custom-search-input` on admin pages.

The pill clips its children (`overflow: hidden`) so square corners can't poke through the 10px radius. Children must not
re-round their corners to match, and nothing inside the pill may overflow it — if a typeahead or suggestion list is ever
added, it will need to be positioned outside the wrapper.

## Phase 9 - NTH

**Objective:** Fix remaining issues if there is time. Otherwise, defer to next release.

### Tasks

- [ ] Journal page navigation buttons (show previous/next) duplication.

---

## Tracking Log

- YYYY-MM-DD — Phase started/completed, notes, blockers, follow-up.
- 2026-08-06 — Phase 1 started.
- 2026-08-10 - Phase 1 completed. Bootstrap 5 assets loaded, Popper included, layout data attributes migrated.
    - Temporary bridge CSS added for float/text/img classes. No fatal JS errors on initial load; main nav collapse
      works.
    - Next: Phase 2 global markup migration.
- 2026-08-11 - Updated and fixed navbar styles, with mobile collapsable menu working. Verified no BS3 data attributes
  remain in layouts.
- 2026-08-12 - Phase 2 started. Global data attributes migrated in layouts and common partials.
    - Close button markup updated. Utility classes replaced where encountered.
- 2026-08-17 - No BS3 data attributes remain in layouts.
    - Core navigation and global dismissible UI function in BS5.
    - Ran JS legacy plugin grep; migrated active usages; deferred N deprecated-file hits. Legacy plugin API grep now
      returns comment-only hits in transcribe JS.
    - Started on Phase 3.
        - stats page migrated (panel->card, btn-default->btn-secondary, input-group-btn removed), exports/date filters
          verified.
- 2026-08-18 - Phase 3 continued.
- 2026-08-24 - Phase 3 continued:
    - Panel/button/input-group BS3 class cleanup completed (panel->card, btn-default->btn-secondary, input-group-btn
      removed).
- 2026-09-21 - Phase 8: "Standardise button styles" completed.
    - Established colour/size conventions (see Button conventions above). Provisional palette in
      `scss/base/_variables.scss` pending design sign-off.
    - Retired BS2/BS3 dead classes: btn-xs, btn-small, btn-mini, btn-default, icon-*, icon-white, bs3, btn-admin.
      Retired 2015 comp classes: btn-hollow, btn-load, btn-complete, btn-next.
    - Consolidated field help icon to a single CSS rule; taglibs now emit
      `class:'fieldHelp'` only. Removed duplicate rule from digivol-custom.css.
    - Removed global `.btn` size overrides and the `.input-group > .btn`
      sub-pixel margin hack (superseded by the `.custom-search-input` flex fix).
    - Fixed while in scope: project status filters were visible due to dead
      `hide` class; ~12 journal navigation buttons and several fragment buttons had no variant and rendered unstyled;
      two irreversible delete confirmations were styled `btn-primary` instead of `btn-danger`.
    - Duplication noted for later extraction: copy-from-previous-task widget (7 copies), mapping tool (5), project
      filter blocks (3), journal page navigation (7 — tracked in Phase 9).
- 2026-09-21 - Phase 8: "Standardise font sizes & breadcrumbs" completed.
    - Base typography decoupled from the BS3 leftover `scss/bootstrap/_variables.scss`.
      `html { font-size: 100% }` + `body { font-size: $font-size-body }` means the app now honours the user's browser
      font-size setting (WCAG 1.4.4). That file now has no typography consumers.
    - Added a `$font-size-*` rem scale in `scss/base/_variables.scss` and a global h1–h6 scale in
      `scss/modules/_typography.scss`. Page titles drop from 35–40px to 26px; hero headings opt in to 35px.
    - Fixed inverted hierarchy: `.a-feature h3` (14px) was smaller than
      `.a-feature h2` (22px) and is now scoped to `.progress-summary h3`.
    - Replaced ~25 hard-coded px font-sizes with tokens; only two icon-sizing exceptions remain.
    - Breadcrumbs: deleted the dead BS3 `<g:breadcrumb>` / `<g:breadcrumbLink>`
      tags from TwitterBootstrapTagLib (no call sites, emitted BS3 markup); fixed `.breadcrumb-list li .glyphicon` →
      `.fa` so separators get their intended spacing and colour.
    - Links: removed underlines globally; prose links (`p a:not(.btn)`) stay underlined
      because $link-color has only 1.1:1 luminance contrast against
      $body-copy (WCAG 1.4.1). Replaced `outline: none` with `:focus-visible`.
    - Correction to the button task: `btn-complete` was still present at project/index.gsp:105 (missed due to a
      truncated grep). Class removed; the CSS deletion was already correct since the rule targeted `.btn-primary`.
- 2026-09-22 - Phase 8: "Standardise form styles (inc bvp checkboxes)" completed.
  - Root cause: `.form-control { height: 25px }` in `modules/_components.scss`, which seven separate rules across four
    files existed only to undo (`digivol-custom.css` admin/forum/input-group patches, a page `<style>` in
    `template/audioTemplateConfig.gsp`, and two inline `style="height:32px"`). Removed the base rule and all seven
    patches.
  - New `scss/modules/_forms.scss` is now the single owner of form styling.
    `digivol-custom.css` has no form rules left.
  - Fixed `input-group`: removed `height: 38px` + `padding` from the flex wrapper, and un-nested `input-group` from
    `col-*` on the two newsItem datepickers (that combination was the reason for the
    `.input-group[class*="col-"]` patch in both files).
  - Checkboxes: 9 controls had the invalid `class="form-control"`, now
    `form-check-input`; `TranscribeTagLib` (`FieldType.checkbox`) likewise. Removed the
    `input[type='checkbox'].form-control` patch and two inline styles. Switch sizing moved from inline `1.5rem` to
    `.form-switch-lg`
    (`$font-size-xl`, 22px — 2px smaller, aligned to the scale).
  - Focus: removed three hand-rolled BS3 blue glows (a 16-selector BS2 list in
    `_components.scss`, plus duplicate `.admin` and `.forum` rules), all of which set `outline: 0`. Added
    `$focus-ring-color` (= `$link-color`) and themed `.form-control` / `.form-select` / `.form-check-input` focus to
    match `a:focus-visible`. `<select>` previously had no focus style at all because the old selector was
    `select[type="text"]`, which cannot match.
  - Deleted 48 `form-horizontal` and 3 `control-group` occurrences across 41 files (5 commits, split by area). Neither
    class has had any CSS since BS4; they were pure residue. Corrects the "~31" estimate in the initial audit, which was
    based on cap-truncated greps.
  - Deleted `.form-control.required .form-label` — `.form-label` is never a descendant of `.form-control`, so it had
    never matched.
  - Bugs fixed while in scope: duplicated `class="form-control form-control"`
    on the newsItem create datepicker; missing `</div>` in
    `project/editMapSettings.gsp` (three opens, two closes — the map row and alert were nested inside the form-group).
    Committed separately.
  - Correction to 2026-09-21: the button-styles entry records removing the `.input-group > .btn` hack, but `.input-group` itself retained a
    `height: 38px` + `padding: 6px 12px` override in `digivol-custom.css` until now.
  - Deliberately not done: `.form-group` retained rather than swept to `mb-*`     utilities (~400 call sites, no visual gain); `form-control` → `form-select`
    deferred; `has-error` → `is-invalid` deferred (adds feedback that doesn't exist today — a behaviour change, not a style fix).
- 2026-09-22 — Phase 8: "Standardise search form styles" completed.
  - Six visual treatments of one control reduced to three documented conventions: volunteer-facing (4 sites) now mirrors
    the navbar pill, admin (5 sites) now mirrors `task/list`'s `input-group` +
    `btn btn-sm btn-primary`, bare filter fields left bare.
  - Component CSS moved from `layouts/_nav.scss` to `modules/_search.scss`. It had 10 of its 11 call sites in page body
    content.
  - Removed the last fixed `height` on a `.form-control` (35px on the search input) — the Phase 8 form sweep missed it
    because it was in `_nav.scss`. The pill height is now `min-height` on the wrapper.
  - Retired four copies of `border-radius: 4px !important` scoped to
    `.custom-search-input` (notebook-2 `_newsItems.scss` plus three page
    `<style>` blocks) and the `border-radius: 0 !important` they were fighting. The unscoped `.btn` half of those rules
    is untouched and stays on the notebook-2 follow-up list.
  - a11y: 17 search/filter inputs had no accessible name (placeholder only)
    and 11 icon-only buttons had none either. All now have `visually-hidden`
    labels. Volunteer-facing search gained a real `<form role="search">`, replacing paired `keydown(13)` + `click`
    handlers with one `submit`
    handler, and `type="search"`.
  - Correction to the plan: the sign-off called for a GET `<form>` on the volunteer pages. Not done — every `doSearch()`
    hand-builds a URL carrying
    `mode`/`statusFilter`/`activeFilter`/`sort`/`order`, which a plain GET form would drop. The form intercepts `submit`
    and calls the existing JS.
  - `float: right` moved from the base rule to `.body`; in the navbar the element is a flex item, so it had always been
    a no-op there.
  - Deliberately not done: renaming `.custom-search-input`; notebook-2
    `.nav-dropdown` search fields; the BS2 locality/collectionEvent fragments.
  - Correction, same day: the a11y labels were initially placed inside
    `.input-group`, which made the input `:not(:first-child)` and squared its corners (admin) and pulled it 1px over the
    pill border (volunteer). Labels moved outside the group. The pill additionally needed `overflow: hidden`, since the
    square inner control extends ~3px past a 10px arc at the corner.