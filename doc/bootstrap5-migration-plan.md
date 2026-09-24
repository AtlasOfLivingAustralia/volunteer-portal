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

Work the groups in the order below. The order is a dependency/efficiency sequence, not a priority cut — everything here
ships before release. Shared conventions land before the pages that consume them, legacy markup is deleted before
anything restyles it, and the CSS ownership moves happen last so no task is rebased mid-flight.

Behaviour bugs found while styling live in **Phase 8a**, not here.

#### Completed

- [X] Standardise button styles
- [X] Standardise font sizes & breadcrumbs
- [X] Standardise form styles (inc bvp checkboxes)
- [X] Standardise search form styles
  - [X] Volunteer facing search form should mirror navbar search field
  - [X] Admin search form field should mirror task/list
- [X] Fix pagination styles
- [X] Fix date picker styles
- [X] Fix file upload browse button style
- [X] Help text icons
- [X] `.form-control { padding: 5px 8px }` (`modules/_forms.scss` 27) silently disables `.form-control-sm` and
  `.form-control-lg`. Bootstrap sets their padding in `bootstrap.css`, which loads first, so our unqualified
  `.form-control` rule wins at equal specificity and both size modifiers become inert (font-size and border-radius
  still apply). Found during the file-upload task, which is why no upload uses `form-control-sm`.
- [X] `project/index.gsp` 105 — `<a disabled="disabled">` is invalid; `disabled`
  is not an anchor attribute. Needs `class="disabled"` + `aria-disabled="true"`
    + `tabindex="-1"`. (Fold into the a11y item.)
- [X] `project/index.gsp` 76/82/94 — tutorial panel `<h4>` headings dropped from 24px to 16px with the new scale.
  Confirm they still read as headings; if not, adjust `font-weight` rather than reintroducing a size override.
- [X] `newsItem/create.gsp` 24 loads bootstrap-datepicker CSS from a public CDN — external runtime dependency and
  supply-chain exposure on an admin page. Vendor it with the other assets.
- [X] `TranscribeTagLib.getWidgetHtml` has 15 widget branches and no tests. It is private and depends on `Task`,
  `TemplateField`, `field.template.viewParams`
  and GORM statics (`ValidationRule`, `Picklist`), so a unit test currently costs more than it's worth.
    - Prompt: "Decide whether to separate widget rendering from GORM lookups to make it testable, or accept it as
      untested legacy."
- [X] `.btn-file input[type=file]` (`digivol-custom.css` 30–44) is `opacity: 0`
  **and** `outline: none`, and the visible `.btn-file` has no `:focus-within`
  style — the file picker gives keyboard users no focus indicator.
    - Resolved 2026-09-23 by deleting `.btn-file` and the JS wrapper entirely rather than adding a ring. The native
      `input[type=file].form-control` is a real focusable control and takes the standard `.form-control:focus` ring.
- [X] **Confirm the pagination arrows should now read "Previous"/"Next".**
  Fixing the `default.paginate.*` lookup means English users now see words where they saw `«` / `»` for 15 years. The
  alternative is to change the *properties*
  to `&laquo;` / `&raquo;` in all 16 locale files and keep the glyphs. The arrows now carry `aria-label`, so the
  accessible name no longer depends on the visible text either way.
    - Prompt: "Decide glyphs or words for the pagination arrows. If glyphs, change
      `default.paginate.prev`/`.next` in all 16 `messages*.properties` rather than reverting the taglib lookup."

---

#### 1. Legacy sweep (BS2 + 2015 design)

*First: deleting dead markup and stylesheets shrinks the surface every later audit has to grep.*

- [X] Remove 2015 static design and dead css classes
    - Includes `static-design/20151006/css/bootstrap.css` — precompiled Bootstrap
      3.3.5 carrying the only `.pagination` and `.pager` component CSS left in the
      repo. Not referenced by the app; unrelated to `scss/bootstrap/_variables.scss`.
- [X] BS2 grid classes still live (`row-fluid`, `span1`–`span12`) — locality/ collectionEvent searchFragment, picklist
  images/wildcount/edit, user/notebookMainFragment, layouts/transcribeTool. Layouts currently collapse to full-width
  stacked divs.
- [X] BS2 form scaffolding (`form-horizontal`, `control-group`, `controls`)
  throughout fragments.
- [X] Sweep remaining `hide` → `d-none` outside the project filter blocks.
- [X] Dead BS2/BS3 classes found during the form sweep: `.well`
  (`user/edit.gsp` 108) and `.form` (`template/create.gsp` 30). Neither has any CSS. Fold into the BS2 grid/scaffolding
  sweep.

#### 2. Component standardisation

*Establishes the conventions groups 3–5 consume. Blocked by the Bootbox and tag-taxonomy open decisions below.*

- [ ] Standardise table styles
- [ ] Standardise modal styles (BS5 vs Bootbox)
- [ ] Fix aria-hidden warnings (if sticking with bootbox - see specimenLabelTranscribe)
- [ ] Standardise alert styles
- [ ] Tag styles are broken (label, label- *, pill, pill-*, badge, badge-*)
- [ ] Dropdown menu styles (inc double caret)
- [ ] `.progress > .bar` (BS2) in `picklist/wildcount.gsp` 55–57 and its two JS handlers at 128/133. BS5 uses
  `.progress-bar`, so the CSV upload progress bar has no fill. Found during the BS2 sweep on 2026-09-24; left alone
  because it is a component, not grid/scaffolding, and the fix touches JS.

#### 3. Forms completion

*Finishes the form conventions established 2026-09-22; everything here was explicitly deferred from that task.*

- [ ] `form-control` on `<select>` should be `form-select` (~40+ sites). The `frontPage/edit.gsp` 230–232 half of this
  item is resolved — that block was dead (the page has no date field) and was deleted on 2026-09-23. Remaining known
  sites include `report/userReport.gsp` 80 and `task/list.gsp` 60.
- [ ] `task/list.gsp` 60 — `style="height:32px"` on `<select class="form-control statusFilter">`. The last survivor of
  the `height: 25px` era; the same select appears without it in `task/adminList.gsp` 119, `newsItem/manage.gsp` 33,
  `tutorials/manage.gsp` 94,
  `task/manageUploads.gsp` 48 and `project/manage.gsp` 110. Fold into the
  `form-control` → `form-select` sweep.
- [ ] Field-level validation feedback is absent. `hasErrors(bean:…, 'has-error')`
  appears throughout the GSPs but `has-error` is BS3 and has zero CSS anywhere;
  `help-block` has zero occurrences. Invalid fields render no visual feedback.
    - Prompt: "Migrate `has-error` to BS5 `is-invalid` + `invalid-feedback`. Decide whether the message comes from the
      Grails `hasErrors`/`fieldError`
      server-side path, client-side constraint validation, or both."
- [ ] Required-field marking is inconsistent. Only a few `.form-group`s carry
  `required` (e.g. `achievementDescription/_form.gsp` 2, 12, 22); many fields set the HTML `required` attribute with no
  class and show no asterisk; others hard-code `*` in the label text (`newsItem/create.gsp` 57, 64, 72, 80), which would
  double up if the class were added.
  - Prompt: "Pick one source of truth — derive the asterisk from the `required`
    attribute, or apply `.form-group.required` everywhere — then strip the hard-coded asterisks. Confirm the
    requirement is announced to screen readers, since a CSS `:after` asterisk is not."
- [ ] Date inputs are `type="text"` `required` with no `pattern` and no visible format hint, while the server parses
  `dd/MM/yyyy` (`NewsItemController` 122–124, 205–207). A typed `2026-03-01` fails server-side and, per the `has-error`
  item, renders no feedback. Fold into the field-level validation item.
- [ ] `report/userReport.gsp` 68/76/86 and `report/projectSummary.gsp` 24 put
  `input-group` and `col-*` on the same element (latent layout bug), and use BS3 `col-sm-offset-3` instead of
  `offset-sm-3` (currently a no-op).
- [ ] `report/userReport.gsp` — BS3 residue left in place during the date picker task: `input-sm` at 69, 71, 80 (class
  has no CSS since BS4), and `.float-right` at 37–47, which redefines a BS3 float utility as an absolutely-positioned
  overlay. Rename to something that isn't a Bootstrap class name.
- [ ] No `accept` attribute on any of the 13 remaining native file inputs. Two were added on 2026-09-23 where the
  client already enforced the same rule (`achievementDescription/_form.gsp` `image/*`, `picklist/wildcount.gsp`
  `.csv`). The rest accept anything and fail server-side.
    - Prompt: "Confirm the permitted types per upload endpoint, then add matching `accept` attributes. Note `accept`
      is a filter, not validation — server-side checks must stay."
- [ ] `achievementDescription/_form.gsp` line 83-84 - there is a whitespace gap inside the bordered control. The Upload
  button looks like it is taller than the control creating the whitespace.

#### 4. Chrome: navbar, breadcrumbs, footer

*Global; touching it mid-page-work would invalidate page screenshots.*

- [ ] Navbar fixes
    - [ ] Main Navbar background should be white
    - [ ] Condensed nav doesn't line up with top of the page and it should centered (left half is the back button, right half is the title and profile drop down)
    - [ ] Breadcrumps are not vertically centered in it's section.
    - [ ] Breadcrumbs - truncate long project names, add ellipsis in middle of breadcrumb trail so we see the start and end
        of the name, and add `title` attribute for full name on hover.
    - [ ] `.digivol-logo { font-size: 0.5rem }` (`layouts/_nav.scss` 26)
      - The element's only child is a block-level `<img>` at `width: 100%`, so this declaration appears to be dead or a
      whitespace-collapse hack.
      - Prompt: "Determine whether .digivol-logo's font-size is load-bearing; remove it if not. Check the navbar brand at
        all breakpoints."
- [ ] Footer logo image has the red bar on the right of the image. This was fixed for the logo in the navbar but not the footer.

#### 5. Page-level layout fixes

*Consumes the conventions from groups 2–4.*

- [ ] Project index page with info cards
  - [ ] Add a card background to the container div for the project info. If the project has a background image, the buttons and some text are unreadable.
  - [ ] Widen the progress bar to the full width and put statistics in info cards underneath (e.g. Volunteers, Tasks, Transcribed, Reviewed, etc.)
- [ ] Review Index page
  - [ ] Fix honourboard/contributor styles
- [ ] Stats page
  - [ ] Tab background colour is not correct (should be white)
  - [ ] Card header needs a padding-top. Determine if this is a BS5 issue or a custom CSS issue.
  - [ ] As does .container (or p tag). See `stats/index.gsp` line 23-27
- [ ] Institution/Project/Custom landing page lists
  - [ ] Institution list - each row should be 2 cards
  - [ ] Project list - Grid layout settings icon should be on the right side of the card, not the left and over the top of the image.
  - [ ] Project list - Table layout image does not resize correctly.
- [ ] Template edit collapsable list - each list should be the width of the page
- [ ] Custom landing page admin
  - [ ] Modernise index page - remove description and fix action buttons. Landing page name fontsize is too large. Bring in line with other admin lists (i.e. expeditions.)
- [ ] Update edit action icons from fa-edit to fa-pencil (consistency)
  - [ ] Update news item edit page delete image button to no icon and btn-outline-delete.
- [ ] Questionaire template is broken (BS5 requires data-bs-target / data-bs-slide-to)

#### 6. Accessibility sweep

*After the markup settles, so none of it is done twice.*

- [ ] Keyboard inaccessible buttons/a11y
    - [ ] `fieldHelp` uses `<a href="#">` + `tabindex="-1"` — tooltip is keyboard-unreachable. Should be
      `<button type="button">`.
    - [ ] `newsItem/manage.gsp` 119 — `<span class="btn">` as an edit control.
    - [ ] `.btn { outline: none }` removes the focus ring app-wide (WCAG 2.4.7)
      — replace with `:focus-visible` (see Step 5-iii).
- [ ] Upload progress and status regions are not announced: `#uploadingMessage`
  (`task/selectImagesForStagingFragment.gsp` 21) and `#upload-progress`
  (`achievementDescription/_form.gsp` 87) toggle visibility with no `role="status"` / `aria-live`. Screen-reader users
  get no feedback that an upload started or finished.
- [ ] `landingPageAdmin/editImage.gsp` 52–56 auto-submits the form on `change`
  with no confirmation and no announcement. Selecting a file immediately uploads and reloads. Working as built, but
  surprising.
    - Prompt: "Decide whether the hero image upload should keep auto-submit or gain an explicit Upload button like
      every other upload in the app."
- [ ] Heading semantics / document outline (fold into "Keyboard inaccessible buttons/a11y" or track separately)
    - `template/audioTemplateConfig.gsp` 47 and 154, and
      `template/wildlifeTemplateConfig.gsp` 42 and 160, each render two `<h1>`
      elements on one page; the second ("Animals") is a sub-section and should be
      `<h2>`.
    - `<h4>Step 1</h4>`, `<h4>EITHER</h4>`, `<h4>OR</h4>` in the specimen/label transcribe templates are layout labels,
      not headings, and create empty outline levels.
    - Prompt: "Fix the heading document outline: one h1 per page, no skipped levels, and no headings used purely for
      visual weight. Convert the transcribe step labels to non-heading elements without changing the grid layout."
- [ ] `PaginationTagLib` accepts an `ariaLabel` attribute that no call site passes — every paginator uses the default
  "Pagination". Added during the rewrite in anticipation of pages with two paginators; that case exists
  (`forum/index.gsp` 71/220, `user/show.gsp` 135/238) but both currently emit the same name.
    - Prompt: "Either give the duplicated paginators distinct `ariaLabel` values (e.g. 'Topics, top' / 'Topics,
      bottom'), or delete the attribute as speculative generality. Two `<nav>`s with the same accessible name on one
      page is a real, if minor, screen-reader defect."

#### 7. CSS ownership, consolidation & dead code

*Last: pure consolidation of whatever survives groups 1–6.*

- [ ] `.custom-search-input` component CSS still lives in `layouts/_nav.scss`
  163–230, not `modules/_search.scss`, which holds only two media queries and
  `#btnSearch`. The search-forms task recorded the move as done; only the responsive overrides actually moved. The
  conventions section names `modules/_search.scss` as the owner, so the file and the doc currently disagree.
    - Prompt: "Move the `.custom-search-input` block out of `layouts/_nav.scss`
      into `modules/_search.scss` so the documented owner is the real one, checking that `main.scss` import order
      keeps the media queries after the base rules."
- [ ] `modules/_search.scss` — the `$screen-md`–`$screen-lg` media query still carries four `!important` declarations
  inherited from `_nav.scss`. With the float now scoped to `.body`, check whether any are still needed.
- [ ] `.card-filter { margin-top: -12px }` (`modules/_components.scss` 349) exists to compensate for the floated,
  fixed-width search pill. Re-check whether it is still required now that the admin pages no longer use that wrapper.
- [ ] Audit the remaining bare element selectors inside component blocks for the same shape as the `.modal select,
  input` margin removed on 2026-09-23 — a blanket rule on `input`/`select`/`a`
  inside a component, which silently reaches controls it was never written for. `notebook-2/_forum.scss` 62 and
  `notebook-2/_newsItems.scss` 60 are the known remaining pairs; both set padding/width/font-size rather than margin,
  so neither is currently harmful.
- [ ] Review the font-size overrides in `digivol-custom.css`: live off-scale values at 89 (`75%`), 101 (`12px`), 126
  (`larger`), 160 (`12px`), 243 (`16px`), 253 (`18px`), 315 (`inherit`). The file loads after the SCSS, so these beat
  the `$font-size-*` scale. Line 169 is a commented-out
  `.admin h1 { font-size: 2.5em !important }` — dead, delete. The `100px`
  `.btn-file` glyph hack noted here previously is gone — the whole rule was deleted on 2026-09-23. Line numbers in this
  item predate that deletion and are now ~19 lines out.
    - Prompt: "Tokenise or delete each font-size in digivol-custom.css against the `$font-size-*` scale. Then decide
      whether digivol-custom.css should exist at all, or be folded into the SCSS pipeline so load order stops being a
      factor — it now has no form or file-upload rules left."
- [ ] `layouts/_commonCss.gsp` still calls `<g:pageProperty name="page.primaryColour">`
  four times (18, 21, 28, 37) now that `--brand-primary` exists at the top of the block. Consolidating would leave one
  source of truth for the branding colour. Note line 21 passes it through `<cl:hexToRbg>`, so that one needs the raw
  hex, not the custom property.
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
    - [ ] `notebook-reset.css` 263 sets `::-webkit-file-upload-button { appearance: button; font: inherit }` unscoped.
        Harmless today — it only restores defaults our theming then overrides — but it is a global pseudo-element rule in a
        file that loads outside the SCSS pipeline. Fold into the digivol-custom / stylesheet-consolidation item.
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
- [ ] `newsItem/create.gsp` and `newsItem/edit.gsp` are ~90% identical, including the whole date picker block. Add to
  the extraction backlog alongside the copy-from-previous-task widget and mapping tool.

#### 8. Manual review (no AI)

*Run against the finished conventions, not before.*

- [ ] Transcribe pages
  - [ ] Review each transcription template view (manually, no AI).
  - [ ] **Inspect the 2026-09-24 `.well` → `.card` conversions.** 25 containers that rendered flat now draw a border
    and background. Highest risk: `admin/tools.gsp` and `admin/mappingTool.gsp`, where the new cards sit inside an
    existing `.card` > `.card-body` (card-in-card); and the 10 transcribe sections, which also gain the
    `.transcribeSection .row` gutters that were previously inert.
- [ ] `_dateWidget.gsp` 16 and 48 — `(from)` / `(to)` are bare text in a `col-md-3`, not `<label>`s, and the six inputs
  are identified by placeholder only. Fold into the transcribe pages task.
- [ ] Review form layout on all admin pages (No AI)

#### Open decisions

Each needs an answer before the group it blocks starts. All still ship this release — deciding is the work, not
deferring.

- [ ] Design decision: should required-field labels be bold? A
  `.form-control.required .form-label { font-weight: bold }` rule existed but had never matched, so it was deleted
  rather than silently activated. *(Blocks group 3.)*
- [ ] Volunteer search forms have no `action` and no hidden inputs, so they are still JS-only and the `<form>` is
  decorative on submit.
    - Prompt: "Decide whether volunteer search should work without JS. If so, give each form a real GET action plus
      hidden inputs for `mode`/`statusFilter`/
      `activeFilter`/`sort`/`order` and delete the URL-building JS."
- [ ] `project/list.gsp`, `institution/list.gsp` and `institution/index.gsp` do not echo `params.q` back into the search
  input — the term appears only as a removable `.currentFilter` tag. `newsItem/manage`, `tutorials/manage`,
  `task/manageUploads` and `picklist/show` do echo it. Inconsistent.
    - Prompt: "Pick one: echo the term in the field, or show it as a removable tag."
- [ ] `stats/index.gsp` 312 — the date-range Search button is `btn-sm btn-primary` next to default-size trigger
  buttons. Left as-is because the search conventions call for `btn-sm btn-primary` on admin filters.
    - Prompt: "Decide whether an admin filter button adjacent to default-size controls should match its neighbours or
      the filter convention. This is the first place the two rules conflict." *(Blocks group 5, stats page.)*
- [ ] angular-ui-bootstrap 1.3.3 datepicker/timepicker emit `btn-default` + glyphicons — renders unstyled. Legacy
  library, maintenance only. The surrounding markup in `stats/index.gsp` 275–314 was migrated to BS5 on 2026-09-23, but
  the **popup panel itself is still unstyled** — the directive templates are compiled into the vendor bundle.
    - Prompt: "Decide whether the stats date range keeps angular-ui-bootstrap with a compatibility shim scoped to
      `.uib-datepicker-popup`, or is rewritten to reuse the vendored bootstrap-datepicker outside Angular. A shim means
      reintroducing `btn-default`/`glyphicon` selectors the phase has otherwise deleted — scope it tightly or not at
      all." *(Blocks group 5, stats page.)*
- [ ] No `pagination-sm` variant. Admin tables use the default size like everything else. Deferred with no evidence it's
  wanted — revisit only if the dense admin lists look unbalanced.

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

There is one `.form-control` size. `.form-control-sm` / `.form-control-lg` are inert: `_forms.scss` sets an
unqualified `padding: 5px 8px` that beats Bootstrap's modifier padding at equal specificity. Do not use them, and do
not scope the override to re-enable them. Use `.form-condensed` if a form needs to be tighter.

Focus rings are themed on `$focus-ring-color` (= `$link-color`) so form controls match `a:focus-visible` in
`base/_base.scss`. Never `outline: none`
or `outline: 0` on a focusable control (WCAG 2.4.7).

**Removed — do not reintroduce:**
`form-horizontal`, `control-group`, `controls`, `control-label`, `input-xlarge`/`-large`/`-medium`/`-small`, `uneditable-input` (BS2);
`has-error`, `help-block` (BS3 — use `is-invalid` / `invalid-feedback` / `form-text`); `form-control` on a checkbox or radio; fixed
`height` on `.form-control`; `select[type="text"]` (matches nothing), `form-control-sm`, `form-control-lg`.

Note: `form-control` **is** correct on `<input type="file">` — Bootstrap 5 styles it. See "File uploads" below. An
earlier version of this list banned it, which was a BS3 carry-over.

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

#### Pagination

All pagination markup is emitted by `PaginationTagLib` (`<cl:paginate>`). Call sites pass data, not classes. Never
hand-write `.pagination`, `.page-item` or
`.page-link` in a GSP, and never wrap the tag in a positioning `<div>` — the
`<ul>` centres itself.

| Class                       | Meaning                                                     |
|-----------------------------|-------------------------------------------------------------|
| `.pagination`               | The `<ul>`. Emitted by the taglib. Centred by default       |
| `.pagination-end`           | Right-aligns the paginator. notebook-2 pages only (5 sites) |
| `.page-item` / `.page-link` | Emitted by the taglib                                       |

Owned by `scss/modules/_pagination.scss`, imported from `main.scss` after
`modules/forms`. Bootstrap 5's own `.pagination` rules supply the box model; our file only themes colour, alignment and
focus.

The active-step colour is per-institution. `layouts/_commonCss.gsp` sets
`--brand-primary` on `:root` from `page.primaryColour`; the SCSS reads
`var(--brand-primary, #{$brand-color})`. Do not reintroduce a `.pagination`
selector into that inline `<style>` block — add the custom property instead. That block loads last and silently wins
over the SCSS.

`prev=""` / `next=""` suppresses an arrow entirely. The taglib tests
`attrs.prev != null`, not truthiness, because `""` is falsy in Groovy.

Arrow text comes from `default.paginate.prev` / `default.paginate.next` in
`messages.properties` (16 locales). The `&laquo;` / `&raquo;` literals in the taglib are the fallback for a missing key,
not the default.

**Removed — do not reintroduce:** `.pagination` on a wrapper `<div>`; nested
`div.pagination > ul.pagination`; BS3 child selectors (`.pagination > li > a`,
`.pagination > .active > span`); `.pagination-list`, `.pagination-list__item`,
`.pagination-list__item--highlight`; `$pagination-*` and `$pager-*` in
`scss/bootstrap/_variables.scss`; `float: right` on a paginator;
`class="step"` on page links; pagination rules in `digivol-custom.css` or a page
`<style>` block.

#### Date pickers

Four libraries render dates. Do not add a fifth, and do not migrate between them without a reason beyond consistency —
each is load-bearing where it sits.

| Context                             | Mechanism                                                   |
|-------------------------------------|-------------------------------------------------------------|
| GSP form needing a date             | bootstrap-datepicker 1.9.0 on `input[type=text].datepicker` |
| Angular 1 pages (`stats/index.gsp`) | `uib-datepicker-popup`. Legacy, maintenance only            |
| SlickGrid spreadsheet cells         | jQuery UI `datepicker` (`slickgrid.js` `DateEditor`)        |
| Transcribe partial-date ranges      | `_dateWidget.gsp` — six text inputs, not a calendar         |

bootstrap-datepicker is **vendored** at
`assets/lib/compile/bootstrap-datepicker/1.9.0/`, exposed through the
`bootstrap-datepicker` JS and CSS asset manifests. Never load a picker from a CDN.

Single-date markup is `.input-group` > `input.form-control.datepicker` +
`button.btn.btn-outline-secondary.datepicker-trigger` carrying `fa-calendar`,
`aria-hidden="true"` on the `<i>` and a `visually-hidden` label. The visible
`<label for>` sits **outside** the input group, per the search-field rule. Range pickers (`input-daterange`) bind to the
container and open on focus — they need no trigger button.

Trigger handlers must be scoped to `.datepicker-trigger`. A handler bound to
`.input-group-text` captures every input group on the page.

Styling is owned solely by `scss/modules/_datepicker.scss`, imported from
`main.scss` between `modules/components` and `modules/forms`. The selected day reads
`var(--brand-primary, #{$brand-color})`, as pagination does. The vendor stylesheet's own selectors are short and
unprefixed (`.active`, `.today`,
`.prev`, `.next`, `.day`) — **always nest them inside `.datepicker`**. Unscoped,
`.active` collides with nav items and `.page-item.active`.

**Removed — do not reintroduce:** CDN `<link>`/`<script>` for a picker;
`.datepicker` or bare `.active`/`.today`/`.prev`/`.next` rules in a page
`<style>` or in `digivol-custom.css`; `<span class="input-group-text">` as an interactive trigger; unscoped
`$('.input-group-text')` handlers; `fa-th-large`
as a calendar glyph; `templates: { leftArrow / rightArrow }` restating library defaults; `.grails-date`; `form-inline`.

#### File uploads

Bootstrap 5 styles file inputs natively. `<input type="file" class="form-control">` renders a real browse button via
`::file-selector-button` — focusable, localised by the browser, no JavaScript. That is the only sanctioned markup.

| Context                  | Markup                                                                          |
|--------------------------|---------------------------------------------------------------------------------|
| Any file upload          | `<label class="form-label" for="x">` then `<input type="file" id="x" name="x" class="form-control">` |
| Upload with its own button | `.input-group` > the input + the submit button                                |
| Angular template-config pages | `ngf-select` on `<button type="button">`. Legacy, maintenance only         |

The button label is the browser's ("Choose File", "Browse…"), not the app's. This is deliberate — it is the control the
user already knows, and it is correct in every locale without translation.

Theming lives in `scss/modules/_forms.scss` alongside the rest of the form styling. **The negative margin on
`::file-selector-button` must mirror `.form-control`'s padding.** Bootstrap bleeds the button to the edge of the
control with `margin: -0.375rem -0.75rem`, the negative of *its* padding; we override that padding to `5px 8px`, so
the margin has to follow or the button overhangs the border. Only the standard
`::file-selector-button` selector is needed — Blink and WebKit alias `::-webkit-file-upload-button` to it, and our
file loads after `bootstrap.css`.

`form-control-sm` is not used on uploads: the app has one form-control size (see Forms conventions).

**Removed — do not reintroduce:** the `bootstrap.file-input` plugin and
`bootstrapFileInput()`; `.btn-file`, `.file-input-wrapper`, `.file-input-name`;
`data-filename-placement`; `opacity: 0` file inputs; `outline: none` on a file input; a wrapper `<a>` or `<div>` used
as a fake browse button; `btn-default` on an upload wrapper; `border-radius … !important` scoped to an upload wrapper;
`type="file"` on a `<button>`.

## Phase 8a — Behaviour bugs found during styling

**Objective:** Fix the non-styling defects surfaced while working Phase 8. Independent of the Phase 8 groups; can run in
parallel. Ships this release.

### Tasks

- [ ] `TranscribeTagLib` drops `cssClass` for checkbox fields. Every other branch emits `"$cssClass form-control"`; the
  checkbox branch emits only a class literal, so `validate[required]` is lost — **mandatory checkbox fields are not
  validated**. Behaviour bug, not styling.
  - Prompt: "Confirm whether mandatory checkbox fields were ever meant to be enforced, then restore `cssClass` on the
    checkbox branch and cover it."
- [ ] `picklist/show.gsp` 11 — `location.href = "?q=" + query` with no
  `encodeURIComponent`. Any `&`, `#` or `+` in the search term corrupts the query string. Every other `doSearch()` in
  the app encodes. Behaviour bug.
- [ ] `admin/tools.gsp` 68–72 — buttons in a `<g:form>` with no `type="button"`, default to submit.
- [ ] `frontPage/edit.gsp` — "Find an expedition" doesn't fill in the select. The handler (222–228) calls
  `bvp.selectProjectId()` then
  `$("#projectOfTheDay").val(projectId)`, but the select is populated by
  `<cl:projectSelectGrouped archiveFlag="${false}" inactiveFlag="${false}"/>`
  (49). If the chosen expedition is archived or inactive there is no matching
  `<option>`, so jQuery's `.val()` silently no-ops and the previous value stays.
    - Prompt: "Decide whether the finder should be restricted to the same active/non-archived set as the select, or
      whether picking an archived expedition should inject the option. Add visible feedback when the selection can't be
      applied."
- [ ] Fix tooltips on wildlife spotter config (create/destroy on maximise/minimise)

---

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
  - **Correction, 2026-09-23:** this entry states the component CSS "moved from `layouts/_nav.scss` to
    `modules/_search.scss`". Only the responsive overrides moved. The `.custom-search-input` component block is still
    in `layouts/_nav.scss` 163–230; `modules/_search.scss` contains two media queries and `#btnSearch` and nothing
    else. Noticed while tracing an unrelated rule. See follow-up.
  - Correction, same day: the a11y labels were initially placed inside
    `.input-group`, which made the input `:not(:first-child)` and squared its corners (admin) and pulled it 1px over the
    pill border (volunteer). Labels moved outside the group. The pill additionally needed `overflow: hidden`, since the
    square inner control extends ~3px past a 10px arc at the corner.
- 2026-09-23 — Phase 8: "Fix pagination styles" completed.
    - Root cause: `TwitterBootstrapTagLib.paginate` emitted Bootstrap 3 markup (`<li class="prev|active|disabled">` +
      bare `<a class="step">`). BS5 styles
      `.page-item` / `.page-link`, neither of which was emitted, so `.pagination`
      contributed only `display: flex` and **every paginator in the app rendered as a row of unstyled inline links** —
      no boxes, borders, active or disabled state. The only surviving styling was an orange `color` from
      `digivol-custom.css` and `_commonCss.gsp`.
    - Taglib renamed `TwitterBootstrapTagLib` → `PaginationTagLib` and moved from the squatted `g` namespace to `cl`,
      resolving the startup warning
      "conflicting tags: ...TwitterBootstrapTagLib.g:paginate vs. ...UrlMappingTagLib.g:paginate". Deleted the
      `fixtaglib` config toggle and its `application.yml` stanza — it existed only to un-shadow the core tag by pulling
      `org.grails.plugins.web.taglib` out of the app context by bean name, and became unreachable once we stopped
      squatting. All 28 call sites converted to `<cl:paginate>`; internal `link(...)` calls qualified to `g.link(...)`.
      Emitted HTML was byte-identical at that commit, so the existing spec passed unmodified.
    - New `scss/modules/_pagination.scss` is the single owner. Deleted the three BS3 rules from `digivol-custom.css`
      (67–79, including two hard-coded
      `#d5502a`) and the five `.pagination` selectors from `_commonCss.gsp`
      (15, 16, 26, 27, 35). Institution branding now travels as a `--brand-primary`
      custom property rather than five repeated `<g:pageProperty>` calls.
    - Removed 22 wrapper `<div class="pagination">` (a flex container wrapping a flex container — which is why
      `div.pagination { text-align: center }` had never been able to centre the `ul`, leaving every paginator
      left-aligned where it was meant to be centred). Plus the stray `class="pagination foo"` at
      `project/_ProjectListDetailsView.gsp` 38 and a redundant `.text-center`
      wrapper at `template/list.gsp` 177.
    - Dropped `.pagination-list` from the 5 notebook-2 sites in favour of
      `.pagination-end`, and deleted `notebook-2/_global.scss` 178–199.
      `.pagination-list__item` and `--highlight` had never matched anything — the taglib has only ever emitted bare
      `<li>`. 20 lines of CSS that never applied.
    - Bugs fixed while in scope:
        - `prev=""` / `next=""` did nothing. The taglib used `attrs.prev ?: …`, and
          `""` is falsy in Groovy, so the fallback arrow always rendered. Three call sites (`institution/list` 135,
          `project/_ProjectListDetailsView` 39,
          `project/_projectListThumbnailView` 38) had been asking to hide the arrows since they were written. **Visible
          change on those three pages.**
        - The i18n lookup used `paginate.prev` / `paginate.next`, but
          `messages.properties` defines `default.paginate.prev` / `.next`. The lookup always fell through to the
          hard-coded `&laquo;` / `&raquo;`, making 15 translation files unreachable. **See follow-up — this changes the
          visible arrows to the words "Previous"/"Next" in English.**
        - `Math.round(Math.ceil(total / max))` → `Math.ceil(...)`.
    - a11y: added `<nav aria-label>`, `aria-current="page"` on the active step,
      `aria-label` on the prev/next links, and `aria-hidden="true"` on disabled arrow spans and the `…` ellipses. None
      of this existed; arrows announced as
      "link" with no accessible name.
    - `TwitterBootstrapTagLibSpec` (one test, asserting an exact BS3 markup string)
      replaced by `PaginationTagLibSpec` — 7 AAA cases covering first/last/single page, `total=0`, suppressed arrows and
      the ellipsis window. Structural assertions rather than one full-string compare, which is what let the old test
      encode BS3 markup unchallenged for years.
    - Deleted `$pagination-*` and `$pager-*` from `scss/bootstrap/_variables.scss`
      (436–470). Both blocks dead; six of the seven `$pager-*` values derived from
      `$pagination-*`, so they had to go together.
    - Correction to the Step 2 proposal: a `.pagination-wrapper` class was proposed for alignment. The actual split
      turned out to be 23 centred / 5 right, which didn't justify it — centring went on `.pagination` itself and the 5
      notebook-2 sites took a `.pagination-end` modifier. The 22 wrapper divs were deleted rather than renamed. Flagged
      as speculative generality at proposal time and confirmed as such at implementation.
    - Correction to the Step 2 audit: the `$pagination-*` block is
      `scss/bootstrap/_variables.scss` 436–454, not 440–449, and is consumed by
      `$pager-*` at 457–470. Deleting the range as originally given failed the Sass compile. The error came from
      grepping `$pagination-`, which returned the six
      `$pager-*` *consumers* and none of the definitions, making the block look 9 lines long. A grep for a variable name
      finds uses; the definition needs a separate look.
    - Also corrected: `template/list.gsp` 178 was recorded in the audit as having no wrapper. It had a `.text-center`
      div.
    - Note: the `.pagination` and `.pager` rules in
      `static-design/20151006/css/bootstrap.css` are precompiled Bootstrap 3.3.5, unrelated to our Sass and untouched.
      They go with the static-design removal.
- 2026-09-23 — Phase 8: "Fix date picker styles" completed.
    - Audit found **four** date libraries across 7 call sites and **zero** picker rules in the SCSS pipeline — every
      picker was styled entirely by a vendor stylesheet or not at all.
    - bootstrap-datepicker 1.9.0 vendored to `assets/lib/compile/bootstrap-datepicker/1.9.0/` with JS and CSS asset
      manifests. Removed 6 CDN `<link>`/`<script>` tags (unpinned, no SRI) from `newsItem/create`, `newsItem/edit` and
      `report/userReport` — all three are admin pages that previously broke if cdnjs was unreachable.
    - New `scss/modules/_datepicker.scss` is the single owner. Both `newsItem` page `<style>` blocks deleted outright,
      which also removed two copies of `.btn { border-radius: 4px !important }` — the exact pattern retired in the
      search-forms task, reintroduced since.
    - `report/userReport.gsp` 15–21 defined `.today, .active { font-weight: bold }` and a `cursor` rule on `.prev`,
      `.next`, `.day`, `.month`, `.year`, `.datepicker-switch` **unscoped**. `.active` is a Bootstrap class, so on that
      admin page the rule bolded every active nav item and `.page-item.active` — silently undoing part of yesterday's
      pagination work. Rules moved into `.datepicker` in the SCSS.
    - Trigger markup: `<span class="input-group-text">` → `<button type="button" class="btn btn-outline-secondary">`
      with `fa-calendar` and a `visually-hidden` label. The picker had been **keyboard-unreachable** on both newsItem
      pages. Handler rescoped from the page-wide `.input-group-text` to `.datepicker-trigger`.
    - `stats/index.gsp` dateRange template: dropped `form-inline` (removed in BS5, so the three groups had not been
      laying out inline), unwrapped three `<label>`s that enclosed block elements with no `for`, gave both icon-only
      trigger buttons accessible names and a matching size, `form-control` → `form-select`. The `uib-datepicker-popup`
      directive is untouched and its popup is still unstyled — see follow-up.
    - Deleted dead code: `digivol-custom.css` `.admin .grails-date select` (the app's only `<g:datePicker>` is
      `task/edit.gsp` 92, whose body has no `admin` class, so it had never matched) and `frontPage/edit.gsp` 230–232
      (no date field on that page). The latter closes half of the `form-select` follow-up, which had proposed fixing
      the block rather than deleting it.
    - Deliberately not done: jQuery UI `DateEditor` in `slickgrid.js` (self-contained, only consumer of jquery-ui.css);
      `_dateWidget.gsp` (a partial-date range widget, not a calendar); no `<cl:datePicker>` taglib — two call sites on
      near-duplicate pages does not justify one, and it was flagged as speculative generality at proposal time.
    - **Correction to the Step 1 audit:** it recorded 2 bootstrap-datepicker call sites. There are 3 —
      `report/userReport.gsp` was missed. The repo-wide grep capped at 20 results; the cap was flagged and narrower
      greps were run, but all of them targeted the *other* three mechanisms, so the original term was never re-run
      scoped. Only a literal `bootstrap-datepicker` search over `grails-app/views/**` returned the true set. Same
      failure mode as the `$pagination-*` miss on 2026-09-23: a capped grep flagged but not actually re-run for the
      term that mattered.
    - **Correction to Step 3:** the first pass at `newsItem/edit.gsp` dropped the
      `<g:set var="dateExpiresPicker" value="${newsItem?.dateExpires?.format('dd/MM/yyyy')}"/>` and bound the input to
      `params.dateExpiresPicker`, which is empty on a GET. The edit form rendered a blank, `required` expiry date —
      a data-loss risk, not a style bug. Caught on verification and restored before sign-off.
- 2026-09-23 — Phase 8: "Fix file upload browse button style" completed.
    - Root cause: the browse button was never Bootstrap's. A vendored jQuery plugin
      (`assets/lib/compile/bootstrap.file-input/`, 130 lines) wrapped every
      `<input type="file">` in `<a class="file-input-wrapper btn btn-default">`, hid the real input at `opacity: 0`,
      and **tracked the mouse to slide the invisible native button under the cursor** — a 2013 Firefox workaround.
      `btn-default` has had no CSS since BS4, so the wrapper rendered as unstyled text on all 15 upload pages.
    - Bootstrap 5.0.2 styles file inputs natively via `::file-selector-button`
      (`bootstrap.css` 2203–2250). The plugin was reimplementing, badly, a feature already in the vendored stylesheet.
      Deleted the plugin, its asset manifest, 14 `<asset:javascript>` includes and 15 `bootstrapFileInput()` calls;
      all 15 inputs are now `class="form-control"`.
    - **Visible change on 15 pages.** The button now reads "Choose File" / "Browse…" per the browser rather than
      "Browse", and the filename appears beside the button rather than inside it. Signed off before implementation.
    - Three competing sources of truth collapsed to one: `.btn-file` +
      `.btn-file input[type=file]` deleted from `digivol-custom.css` (26–44, including `font-size: 100px`,
      `outline: none` and `opacity: 0`); the plugin's runtime-injected `<style>`
      went with the plugin; the two `.file-input-wrapper { border-radius: 4px !important }` page blocks in
      `tutorials/create` and `tutorials/edit` deleted. That `!important` pattern has now been retired three times
      (search forms, date pickers, here) — it keeps coming back with copy-pasted upload blocks.
    - **Found mid-implementation, not in the audit:** Bootstrap's
      `::file-selector-button` negative margin is the negative of *Bootstrap's*
      `.form-control` padding, and `modules/_forms.scss` 27 overrides that padding to `5px 8px`. Adopting the native
      button without mirroring the margin would have left it overhanging the control border. The theming rule sets
      `margin: -5px -8px` to match. This also exposed that the same override makes `.form-control-sm` / `-lg` inert
      app-wide — new follow-up — resolved 2026-09-23: one size, modifiers retired.
    - a11y: 6 inputs had no `<label>` at all and one
      (`achievementDescription/_form.gsp` 74) pointed `for="badge"` at the hidden field rather than the file input, so
      clicking it did nothing. All fixed. The old wrapper was an `<a>` with no
      `href` — not focusable — so upload was keyboard-operable only by tabbing to an invisible, `outline: none` input.
      The native control is focusable and takes the standard `.form-control:focus` ring, which closes the
      `:focus-within` follow-up by deleting its cause rather than patching it.
    - Bug fixed while in scope: `type="file"` on 10 `<button>` elements across
      `template/audioTemplateConfig.gsp` and `template/wildlifeTemplateConfig.gsp`. Not a valid button `type`, so the
      HTML spec makes them default to **submit** inside their Angular forms. Changed to `type="button"`. Committed
      separately — behaviour, not styling.
    - `template/manageFields.gsp` and `task/loadTaskData.gsp` gained an
      `input-group` so their adjacent submit button stays inline; `form-control` is `display: block; width: 100%` and
      would otherwise have stacked them.
    - Two `accept` attributes added where the client already enforced the same rule two lines later
      (`_form.gsp` `image/*`, `wildcount.gsp` `.csv`). The other 13 inputs are a follow-up, not a silent fix.
    - Deliberately not done: no upload taglib — 15 call sites across 12 forms with different names, ids and
      surrounding layout, flagged as speculative generality at proposal time and confirmed at implementation;
      `ng-file-upload` 9.1.2 left alone beyond the invalid `type` (legacy, maintenance only); `picklist/wildcount.gsp`
      BS2 markup left to the BS2 sweep, only its input and label touched.
    - Verified with `./gradlew assetCompile`; `.form-control::file-selector-button` is present in the compiled
      `digivol.css`. Note a repo-wide grep for `btn-file` still returns hits in
      `build/assets/*.css` — those are stale hashed artifacts from earlier builds, not source.
    - **Correction to the Step 1 audit:** it reported 14 native file inputs from a repo-wide grep that silently capped
      at 20 results. The cap was flagged and the search re-run scoped by directory, which found a 15th
      (`landingPageAdmin/editImage.gsp`, the only `.btn-file` call site — the one page the task was named after).
      Third occurrence of this failure mode after the `$pagination-*` and `bootstrap-datepicker` misses. A capped grep
      must be re-run for the term that matters, not just for adjacent terms.
    - **Correction to the forms conventions:** the "Removed" list had banned
      `form-control` on a file input. True in BS3, wrong in BS5 — it is now the required markup. List amended.
    - **Smoke-test regression, fixed same day.** Whitespace gap under the browse button on file inputs inside modals.
      Cause: `modules/_components.scss` 883 carried a blanket BS2-era
      `.modal { select, input { margin-bottom: 10px } }`. Under the old plugin the real input was
      `position: absolute`, so that margin had no layout effect; as a normal in-flow block it applies. Replaced with
      `.modal .form-group { margin-bottom: 10px }` — spacing belongs to the documented `.form-group` unit, not to bare
      element selectors, which also hit `.input-group` children and break their alignment.
    - Deleted the counter-patch `.admin .modal input { margin-bottom: 0 }`
      (`digivol-custom.css` 168–170), which existed solely to undo the blanket rule on admin pages. Same
      patch-and-counter-patch shape as the seven `height: 25px` patches removed on 2026-09-22; this one survived that
      sweep because it is a `margin`, not a `height`.
    - Blast radius checked before the change: of the 10 modal-bearing views with form controls, 6 use `.form-group`
      and are unaffected; the other 4 (`template/manageFields`, `task/manageUploads`,
      `institutionAdmin/index`, `institutionAdmin/applications`) are all `<body class="admin">`, where the counter-patch
      already zeroed the margin — so the change is a no-op for them. The visible fix lands on non-admin modals, e.g.
      the upload modal hosted by `institutionAdmin/edit.gsp` (`<body>`, no `admin` class).
- 2026-09-23 — form-control sizing decision 
    - Standardised: one `.form-control` size. `.form-control-sm` / `-lg` are documented as inert and listed under
      "Removed — do not reintroduce".
    - Retired: nothing. A workspace grep found zero call sites outside this doc and the unloaded BS3 vendor CSS in
          `static-design/20151006/`, so the "delete the call sites" branch of the prompt was a no-op.
    - No code changed. `_forms.scss` 26–28 and the `::file-selector-button` margin at 37 are unaffected.
    - Corrected: the notes at 765 and 1027, which described the sizing question as open. 
- 2026-09-24 — Phase 8 task list restructured. Document change only; no code touched and **no items added, removed,
  merged or reworded**. Every bullet is verbatim from the previous revision.
    - The flat list of ~60 open items at one level was regrouped into eight headed work packages plus an Open
      decisions subsection, ordered as a dependency/efficiency sequence rather than a priority cut: legacy sweep →
      component standardisation → forms → chrome → page-level → a11y → CSS ownership → manual review. Shared
      conventions now land before the pages that consume them, dead markup is deleted before anything restyles it,
      and the stylesheet-ownership moves are last so no task is rebased mid-flight.
    - The 15 completed `[X]` items were collected under a **Completed** heading at the top of the section rather than
      left interleaved with open work.
    - Five non-styling defects moved verbatim to a new **Phase 8a — Behaviour bugs found during styling**:
      `TranscribeTagLib` checkbox `cssClass`, `picklist/show` encoding, `admin/tools` implicit submit,
      `frontPage/edit` expedition select, wildlife-spotter tooltips. The questionnaire carousel stayed in Phase 8
      group 5 — it is an unfinished BS5 data-attribute migration, not a pre-existing bug. Phase 8's "done when" is now
      about styling only.
    - One formatting correction, no text change: the `Prompt:` under "Field-level validation feedback is absent" was
      a top-level bullet, so it read as a separate task. It is now indented as a child of its item, matching every
      other prompt in the section.
    - Items whose resolution is a judgement call rather than an edit were gathered into **Open decisions**, each
      tagged with the group it blocks. They are decisions to take, not deferrals — everything in Phase 8 and 8a ships
      this release.
    - Known sequencing constraints recorded at the time of the restructure: the Bootbox-vs-BS5 and tag-taxonomy
      decisions block group 2; the `btn-sm` filter-button conflict and the angular-ui-bootstrap datepicker decision
      block the stats page in group 5; the required-label boldness decision blocks group 3.
    - Cross-references preserved where an item says "fold into X" (e.g. `_dateWidget.gsp` labels → transcribe manual
      review; `task/list.gsp` inline height → the `form-select` sweep; `notebook-reset.css` →
      digivol-custom consolidation). The referenced item is now in the same or a named group, so the pointer still
      resolves.
- 2026-09-24 — Phase 8 group 1: BS2 legacy sweep (grid, `.well`, form scaffolding) completed. `static-design/20151006/**`
  deliberately excluded — it is vendored BS3/BS2 with no `<link>` from the app and goes with its own deletion item.
    - **Nothing removed in this task had any CSS.** `.span1`–`.span12`, `.row-fluid`, `.well`, `.well-small`,
      `.well-sm`, `.controls`, `.input-block-level`, `.input-medium` and `.form` have zero rules in the SCSS pipeline
      (the only matches are commented-out blocks in `cameratrap.css` / `audiotranscribe.css` / `wildlifespotter.css`).
      Every "layout" they described had been inert since the BS4 upgrade, so **the visible change is the layout and the
      cards coming back**, not going away.
    - Grid: `locality/searchFragment` (2/4/1/5) and `collectionEvent/searchFragment` (2/2…/2 and 2/2/2/3/3) restored to
      `row` + `col-md-*`; both had been rendering as stacked full-width divs. The remaining nine sites were
      `row-fluid > span12` — a full-width wrapper around a full-width child — and were deleted rather than converted to
      `row > col-12` (`layouts/transcribeTool`, `picklist/images`/`wildcount`/`edit`, `journalTranscribe`). Only
      `task/showDetails` 64/170 became a real `.row`, because its children were already `col-*`.
    - `.well` → `.card` + `.card-body` at 25 sites. The 10 transcribe sections took `card transcribeSection` to match
      `TranscribeTagLib.getWidgetHtml` (634) and the already-migrated `singleSection`/`aerialObservations`/
      `genericLabels` views; they now also get the `.transcribeSection .row` gutters from `modules/_components.scss`
      934, which had never applied. Deleted the five inline paddings that existed to make wells look right
      (`user/edit` ×2 `padding: 10px !important`, `_taskSummary` `padding: 2px`), and moved three `margin-top: 10px`
      to `mt-2`.
    - `class="well-small"` with no `well` (`achievementDescription/index` 55, `landingPageAdmin/index` 59) was deleted
      rather than converted. `.well-small` was only ever a modifier — those two divs never rendered as wells, even in
      BS2, so carding them would have invented a panel that has never existed.
    - Form scaffolding: `form-inline` removed from all 5 sites (BS5 deleted the class, so none of them had been laying
      out inline) — the four admin forms took `d-inline-block` + `pe-2`, replacing `style="display: inline-block"`, and
      the dynamic-rows JS took `d-flex flex-wrap align-items-center gap-2`. `.controls` removed from 4 sites, not the
      1 recorded in the audit — see correction below. `input-block-level` ×2 and `input-medium` ×2 → `form-control` or
      nothing; `class="form"` deleted from `template/create` 30.
    - Deleted `notebookMainFragment.gsp`, `badgesFragment.gsp`, `recentTasksFragment.gsp` and six controller actions.
      `UserController.notebook()` (450) has only ever forwarded to `show()`, which renders the notebook-2 `user/show.gsp`;
      the fragments' sole caller was a commented-out `$.ajax` **inside `notebookMainFragment.gsp` itself**, and their
      `data-switch-tab` hooks have had no JS handler in the repo for years. `transcribedTasksFragment`,
      `savedTasksFragment` and `validatedTasksFragment` had no view file at all and would have 500'd if reached.
      Committed separately — behaviour, not styling.
        - Two traps in that deletion: `ALA_HARVESTABLE` and `SPECIES_AGG_TEMPLATE` **stay**, because
          `UserService.appendNotebookFunctionalityToModel` reads them as `UserController.ALA_HARVESTABLE`;
          `MATCH_ALL`, `FIELD_OBSERVATIONS` and `VALIDATED_TASKS_FOR_USER` went, as did
          `TaskService.getRecentlyTranscribedTasks` (579), whose only caller was `recentTasksFragment`. Also dropped the
          now-unused `SearchResponse` import and `freemarkerService` injection.
        - The dead action duplicated the live service almost line for line, down to the `log.debug` strings, which still
          read `notebookMainFragment.*` in `UserService` 839/855. It had also drifted: the dead copy counted distinct
          projects with a bare `countDistinct("project")` where the live one nests it under `task { }`.
    - Deleted the dead `layoutClass` payload from `_dynamicDatasetRows.gsp` 51/170. It was written into the JS `entries`
      objects and never read by `renderEntries()`, and its `?: 'span1'` default was the last `span1` in the app. **The
      DB column stays** — `_dateWidget.gsp` 3–7 reads `DMY`/`MDY`/`YMD` out of it, and of the 33 distinct
      `template_field.layout_class` values only one (`span6`) is a grid class. That row is inert now that the payload
      is gone; no migration written.
    - Bugs fixed while in scope: unclosed `<span class="transcribeSectionHeaderLabel">` in
      `observationWithGeoTranscribe` 84 and `observationDiaryTranscribe` 84 (the `</div>` closed it implicitly, so the
      "Shrink" link was inside the label span); BS2 `label.checkbox` wrapping its input in
      `collectionEvent/searchFragment` 63 and `cameratrapTranscribe` 23 → `form-check` with a real `for`;
      `task/exportOptionsFragment` 27 had its two buttons in an `.input-group`, which in BS5 joins them into a
      segmented control — now `d-flex gap-2`.
    - a11y while in scope: `Locality`, `Event date` and `Locality` were bare text in a grid cell on the two search
      fragments and are now `<label for>`; the wildcount image search gained a `visually-hidden` label and the
      documented admin `input-group` + `btn btn-sm btn-primary` markup.
    - **Correction to the Step 1 audit:** it reported one `.controls` div (`task/exportOptionsFragment` 28). There are
      four — `project/deleteAllTasksFragment` 12, `project/deleteProjectFragment` 13 and `cameratrapTranscribe` 22 were
      missed. The audit grep combined seven alternations in one pattern and hit the 20-result cap, so the three files
      that sorted after the cap never appeared. Re-running per-term found them. Same failure mode as the
      `$pagination-*`, `bootstrap-datepicker` and `btn-file` misses: **a capped grep must be re-run for each term, not
      just re-run narrower on adjacent terms.** Every count in this entry comes from a single-term grep.
    - **Correction to the Step 1 audit, second:** it listed `input-block-level` nowhere and `input-medium` only at
      `picklist/wildcount` 113/116. `input-block-level` has four sites (`picklist/images`, `picklist/wildcount`,
      `picklist/manage`, `achievementDescription/_form`); it surfaced only when the wildcount search block was opened
      for the well conversion.
    - Deliberately not done: `hide` → `d-none` (unchanged, still open in group 1); `.progress > .bar` in
      `picklist/wildcount` — a BS2 *component* with two JS consumers, moved to group 2 as a new item; re-indenting the
      bodies of the two large `admin/tools.gsp` blocks was done, so those two hunks are large in the diff despite being
      a two-line change.
    - Verified with `./gradlew compileGroovy` (BUILD SUCCESSFUL) and a div-balance check on every edited GSP.
