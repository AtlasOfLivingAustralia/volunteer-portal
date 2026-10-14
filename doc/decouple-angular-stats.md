# Stats Page Angular 1 Decoupling Plan

## Goal

Decouple the Statistics page from Angular UI Bootstrap first, then optionally decouple the remaining Angular 1 dependencies later.

Primary page:
- `grails-app/views/stats/index.gsp`

Shared template currently used by the page:
- `grails-app/views/common/_angularBootstrapTabSet.gsp`

Current dependencies on this page include:
- Angular UI Bootstrap tabs (`uib-tabset`, `uib-tab`)
- Angular 1 controller state (`StatsCtrl`)
- Angular-based date range component
- Angular-based chart directives

This document focuses on removing the tab dependency first, then provides a later path for full Angular 1 removal.

---

## Phase 1: Remove Angular UI Bootstrap tabs

### Why

Angular UI Bootstrap tabs are legacy and do not render with a Bootstrap 5-native look. The page is also using a custom template wrapper that adds more legacy styling.

### Current issues

1. `uib-tabset` and `uib-tab` are Angular UI Bootstrap components.
2. The active tab state is controlled by Angular UI Bootstrap internals, not Bootstrap 5.
3. The custom wrapper in `_angularBootstrapTabSet.gsp` includes `.tab-content-bg`, which is old presentation logic.
4. The page still uses the old `li`-based tab template rather than native BS5 patterns.

### Scope of this phase

Update only the stats page tabs so they:
- look like Bootstrap 5 tabs
- do not rely on Angular UI Bootstrap tab directives
- keep all existing chart/date functionality intact

### Suggested approach

#### Option A: Bootstrap 5 native tabs with minimal JavaScript
- Replace `uib-tabset` / `uib-tab` in `stats/index.gsp`
- Use Bootstrap 5 nav/tab markup
- Keep Angular data bindings inside each pane
- Use Bootstrap tab activation via `data-bs-toggle="tab"`

Pros:
- Closest to BS5 native behavior
- Removes Angular UI Bootstrap dependency for tabs

Cons:
- Requires Bootstrap JS tab behavior to be available on the page

#### Option B: Angular-controlled tab state with Bootstrap 5 markup
- Replace `uib-tabset` / `uib-tab` with simple markup
- Use `statsCtrl.activeTab` or similar state
- Render panes with `ng-class` / `ng-show`

Pros:
- No Bootstrap JS dependency
- Smallest logic change if Angular is already present

Cons:
- Tabs are not fully native Bootstrap JS tabs

### Recommended option for this page

Use Bootstrap 5 markup but keep the active pane controlled by Angular if the page already depends on Angular heavily. This reduces the chance of introducing a new JS dependency mismatch.

---

## Phase 2: Remove the shared tab wrapper

### File to update

- `grails-app/views/common/_angularBootstrapTabSet.gsp`

### What to change

Remove the custom wrapper that adds:
- `<div class="tab-content-bg">`
- extra nested containers that are only there for the old tab presentation

### Result

The tab area should rely on Bootstrap 5 classes and the existing layout containers only.

### SCSS cleanup

Also review:
- `grails-app/assets/scss/modules/_components.scss`

Current rule:
- `.tab-content-bg`

If the wrapper is removed, this CSS should be removed or left unused only temporarily.

---

## Phase 3: Verify the page still works

Test the following:

- first tab is active on page load
- site admin-only tabs still render conditionally
- loading spinners still work
- chart directives still render inside each tab
- download links still work
- date range control still fires stats refresh correctly

---

## Phase 4: Optional full Angular 1 decoupling later

If the goal later is to remove Angular 1 from the page entirely, do it in this order:

1. Replace the tab system
2. Replace the date range control
3. Replace chart directives one by one
4. Replace `StatsCtrl`
5. Remove Angular 1 page bootstrap when nothing depends on it

This reduces risk and keeps the page functional throughout the migration.

---

## Later decoupling checklist

### Step 1: Remove Angular UI Bootstrap tab dependency
- replace `uib-tabset`
- replace `uib-tab`
- remove `notebookTabSet.html`

### Step 2: Replace Angular date range control
- identify the directive behind `date-range`
- build a Bootstrap 5 / vanilla JS date range control
- preserve the same callback behavior

### Step 3: Replace chart directives
- identify `tablechart`, `barchart`, `linechart`, `google-chart`
- decide whether to keep Google Charts or wrap it in plain JS
- preserve data-loading behavior

### Step 4: Replace `StatsCtrl`
- move API calls into a plain JS module or server-rendered data where possible
- keep the same endpoints initially

### Step 5: Remove Angular page bootstrap
- remove `data-ng-app="statApp"` once no directives remain
- remove Angular-only scripts from the page
- verify no other shared template requires Angular 1 on this page

---

## Suggested prompts for future work

### Prompt 1: Replace the tab UI only
> Update `grails-app/views/stats/index.gsp` to stop using Angular UI Bootstrap tabs. Keep the existing statistics behavior, but replace the tab markup with Bootstrap 5-native tabs or equivalent minimal Angular-controlled markup. Preserve the current tab order and the site admin-only tab visibility.

### Prompt 2: Remove the shared wrapper
> Simplify `grails-app/views/common/_angularBootstrapTabSet.gsp` so it no longer adds legacy tab presentation styles. Remove the `.tab-content-bg` wrapper if it is only serving old styling, and keep the markup Bootstrap 5-friendly.

### Prompt 3: Start Angular 1 decoupling
> Audit the Statistics page for Angular 1 dependencies after the tabs have been replaced. Identify each directive, controller binding, and template dependency, then propose the smallest safe replacement path for each one.

### Prompt 4: Replace the date-range component
> Replace the Angular 1 `date-range` component on the Statistics page with a Bootstrap 5-friendly or vanilla JS date range control. Preserve the same inputs, institution selection, and callback behavior.

### Prompt 5: Replace chart directives
> Identify the chart directives used on the Statistics page (`tablechart`, `barchart`, `linechart`, `google-chart`) and propose a migration path that removes Angular 1 while preserving the existing chart output and export-to-CSV behavior.

---

## Migration notes

### Keep the change small
Avoid changing more than one dependency layer at a time:
- tabs first
- shared wrapper second
- Angular 1 controls later

### Avoid speculative rewrites
Do not rewrite the whole statistics page in one pass. The page has multiple dependencies and should be migrated incrementally.

### Test after each phase
After each change, verify:
- tab switching
- conditional admin tabs
- chart rendering
- download actions
- loading states
- date filters

---

## Files likely involved

- `grails-app/views/stats/index.gsp`
- `grails-app/views/common/_angularBootstrapTabSet.gsp`
- `grails-app/assets/scss/modules/_components.scss`
- any JavaScript file that defines `StatsCtrl`
- any JavaScript file that defines `date-range`
- any JavaScript file that defines chart directives

---

## Short recommendation

If the goal is only to modernize the tabs, stop at Phase 1 and Phase 2.

If the goal is to remove Angular 1 from the page later, use this document as the migration roadmap and do the work incrementally.