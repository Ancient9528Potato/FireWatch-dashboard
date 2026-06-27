# FireWatch Alberta — Living Spec

> A pre-season benchmarking dashboard for Alberta Wildfire. It compares each of the 10 forest
> areas against its own 20-year history, by fire count, hectares burned, and cause mix, so a
> planning analyst can recommend where to concentrate crews and prevention effort before peak season.

---

## Objective

**The decision this changes.**
Before each fire season (the planning window runs through April, ahead of the May–Aug peak), Alberta Wildfire decides where to pre-position Initial Attack crews and air tankers, and where to concentrate prevention effort (fire bans, public education, industry restrictions). Today that planning means hand-assembling 20 years of fire records across 10 forest areas and ~15 cause categories.

**The user.**
A risk / emergency-planning analyst at Alberta Wildfire Management Branch. Has fire-domain expertise; is short on time and tooling. Produces a recommendation to the Director of Operations — does not set policy alone.

**The leverage.**
Turns a half-day of spreadsheet assembly into a 5-minute read: which forest areas run hottest relative to their own 20-year norm, whether the load is lightning (→ detection/suppression) or human (→ prevention), with the historical trail behind every number.

**No-dataset sentence.**
*This lets an Alberta wildfire planning analyst see which forest areas are running above their 20-year norm, and whether the cause is preventable, before the season peaks — so they can place crews and prevention effort with a defensible data trail.*

---

## What Good Looks Like

**Testable standards (each one scoreable):**
1. Every percentage carries its N. "High Level is 14% of fires" must render "14% (3,970 / 27,828)".
2. Fire size is reported as **median + 90th percentile + total hectares**, never a bare mean. (Verified: mean 262 ha vs median 0.02 ha — a bare mean is disqualifying.)
3. `SIZE_CLASS` (A–E) is shown as a labelled category, never averaged.
4. Any cause trend that crosses **2012** carries the reclassification note (Agriculture/Government split out of Resident/Other Industry that year).
5. Cause breakdowns using `ACTIVITY_CLASS`/`TRUE_CAUSE` display the null share (those fields are ~61% / ~53% filled).
6. Every view states the **FPA-only** scope where a total could be mistaken for all of Alberta.

**Gold example — the centrepiece answer the dashboard must produce well (real numbers, computed from the connected CSV):**
> **High Level forest area — 20-year benchmark.** 3,970 fires 2006–2025 (14.3% of the FPA total of 27,828). Cause mix: Lightning 47.0% (1,865), Resident 18.9% (752), Incendiary 17.6% (698), Agriculture 4.8% (189), other 11.7% (N = 3,970). Median fire size 0.20 ha; 90th percentile 17.7 ha; **total 2.33M ha** — among the highest in the province, concentrated in escape years (2023, 2019, 2011). **Read:** lightning and human causes are nearly even here, so both detection reach AND prevention matter — unlike a pure-lightning northern area. *(FPA-only; cost and forecast out of scope.)*

**Must-never-produce:**
- Never "causes" / "drives" for a statistical association — use "associated with."
- Never average `SIZE_CLASS`; never a bare "average fire size."
- Never a dollar / cost figure — **no cost field exists in this data.**
- Never a forecast ("next season will…") — this is a historical record.
- Never a climate-attribution claim — no FWI or climate series here.
- Never present an FPA total as an all-Alberta total.
- Never take a side on the full-suppression-vs-managed-fire policy debate.

---

## Scope

**Smallest valuable version (ships Day 2):**
- **Region benchmark view** — each of the 10 forest areas vs. its own 20-year norm: fire count, total + median hectares, and the year flagged when it ran above norm.
- **Cause-mix panel** — the ~15 `GENERAL_CAUSE` categories, with a defined Human-vs-Lightning split, per region and per year, null share shown.
- **Trend line** — annual fire count and hectares burned 2006–2025, with the 2012 cause break marked.
- **Signal panel** — forest areas whose recent 3-year average exceeds their 20-year norm (the "watch this area" list).

**One stretch goal:**
- **Response-time view** — reported → first-suppression lag by region, on the ~71% of fires with that field, gap disclosed. Tells the analyst where early detection is weakest.

**Explicit refusals (and why):**
- Suppression cost optimization — no cost data.
- Real-time / current-season monitoring — the data is a finalized annual record, not a live feed.
- Fire-spread or risk forecasting — out of scope for a historical benchmark.
- Per-fire mapping as the core view — lat/long exists (stretch), but the decision is regional, not per-fire.

---

## Data

**Source:** Alberta Forestry & Parks — Historical Wildfire Database 2006–2025. Open Government Licence – Alberta.
**Connection:** CSV + official data-dictionary PDF connected in `knowledge/survey-data/` — read in full, never pasted.
**One row:** one wildfire incident inside the Forest Protection Area, ignition → extinguishment.
**Representativeness:** full FPA administrative record (27,828 fires); **excludes Mutual Aid fires outside the FPA.**

**Load-bearing facts the agent must not guess (full list in `knowledge/data-cautions.md`):**
- Region = first letter of `FIRE_NUMBER` (10 forest areas); there is no region column.
- `CURRENT_SIZE` is extreme right-skew → median + p90, never bare mean.
- `SIZE_CLASS` A–E is ordinal → never averaged.
- `GENERAL_CAUSE` has ~15 values, not "Lightning vs Human"; cause categories changed in 2012 (and Prescribed Fire only 2012–2016).
- `ACTIVITY_CLASS` / `TRUE_CAUSE` are partially null → show the null share.
- No cost field, no FWI field. FPA-only coverage.

---

## Capabilities

**Agent decides on its own:**
- Chart type best fitting a distribution (bar, box, line, small multiples).
- The plain-language read under each regional comparison.
- Computing 20-year norms and flagging which areas exceed them.

**Behavior fixed in advance (no deviation):**
- Every number shows its N.
- Size → median + p90 + total; never a bare mean; `SIZE_CLASS` never averaged.
- Cross-2012 cause trends always carry the reclassification note.
- Cause-detail views always show null share.
- FPA-only scope stated where totals could mislead.
- No causal language, no cost figures, no forecasts.

---

## Human-in-the-Loop

**Human has the final word on:**
- The deployment / prevention recommendation. The dashboard surfaces the signal; the analyst makes and owns the call.
- Publishing or sharing any view — analyst reviews first.

**Override logging rule (not optional):**
If the analyst overrides a flag or changes a norm threshold (e.g., declares a region comparable across the 2012 break), the dashboard logs **who** changed it, **what** the original flag said, and **why**. No log, no change.

---

## Rejected Alternative

**Considered:** a per-fire operational *monitoring* dashboard ("what's burning right now, by ward").
**Rejected because:** the data is a **finalized annual record through 2025, not a live feed** — there is no "right now" to monitor, so a real-time framing would be a clever build aimed at a decision the data cannot serve. The honest, decision-changing use is **pre-season benchmarking** against 20 years of history. We kept the user (the planning analyst) and the decision (where to place crews and prevention) fixed, and let the data veto the monitoring framing.
