# FireWatch Alberta — Living Spec

> A pre-season benchmarking dashboard for Alberta Wildfire. It compares each of the 10 forest areas against its own 20-year history — by fire count, hectares burned, and cause mix — so a planning analyst can recommend where to concentrate crews and prevention effort before peak season.
>
> *This file is the spec the agent reads at the start of every run. Change a line here and you change the next run's behavior. The test of any line: would deleting it change the output? If not, cut it.*

---

## 1 · Objective — why this project exists

Before each fire season (the planning window runs through April, ahead of the May–Aug peak), Alberta Wildfire must decide where to pre-position resources and prevention effort. Today that planning means hand-assembling 20 years of fire records across 10 forest areas and ~15 cause categories — a half-day of spreadsheet work that hides the signal.

**The leverage.** This turns that half-day into a 5-minute read: which forest areas are running above their own 20-year norm, and whether the load is lightning (→ detection / suppression) or human (→ prevention), with the historical trail behind every number.

**No-dataset sentence.**
*This lets an Alberta wildfire planning analyst see which forest areas are running above their 20-year norm, and whether the cause is preventable, before the season peaks — so they can place crews and prevention effort with a defensible data trail.*

---

## 2 · User & Decision — who uses it, what they decide

**The user.** A risk / emergency-planning analyst at Alberta Wildfire Management Branch. Has fire-domain expertise; is short on time and tooling. Produces a recommendation to the Director of Operations — **does not set policy alone.**

**The decision it changes (two levers):**
1. **Where to pre-position** Initial Attack crews and air tankers before the season.
2. **Where to concentrate prevention** — fire bans, public education, industry restrictions.

**Why it matters.** Resources placed in a low-risk area are wasted; under-covering a hot area lets a fire escape, where suppression effort multiplies. The decision is **regional** (which of the 10 areas), not per-fire.

---

## 3 · Success Criteria — what counts as good

**Testable standards (each one scoreable):**
1. Every percentage carries its N. "High Level is 14% of fires" must render "14.3% (3,970 / 27,828)".
2. Fire size is reported as **median + 90th percentile + total hectares**, never a bare mean. (Verified: mean 262 ha vs median 0.02 ha — a bare mean is disqualifying.)
3. `SIZE_CLASS` (A–E) is shown as a labelled category, never averaged.
4. Any cause trend that crosses **2012** carries the reclassification note (Agriculture/Government split out of Resident/Other Industry that year).
5. Cause breakdowns using `ACTIVITY_CLASS` / `TRUE_CAUSE` display the null share (those fields are ~61% / ~53% filled province-wide).
6. Every view states the **FPA-only** scope (Forest Protection Area — the data excludes "Mutual Aid" fires outside it) where a total could be mistaken for all of Alberta.

**Gold example — the centrepiece answer the dashboard must produce well (real numbers, computed from the connected CSV):**
> **High Level forest area — 20-year benchmark.** 3,970 fires 2006–2025 (14.3% of the FPA total of 27,828). Cause mix: Lightning 47.0% (1,865), Resident 18.9% (752), Incendiary 17.6% (698), Agriculture 4.8% (189), other 11.7% (N = 3,970). Median fire size 0.20 ha; 90th percentile 17.7 ha; **total 2.33M ha** — among the highest in the province, concentrated in escape years (2023, 2019, 2011). **Read:** lightning and human causes are nearly even here, so both detection reach AND prevention matter — unlike a pure-lightning northern area. *(FPA-only; cost and forecast out of scope.)*

---

## 4 · Scope — what's in, what's out

**Smallest valuable version (ships Day 2):**
- **Region benchmark view** — each of the 10 forest areas vs. its own 20-year norm: fire count, total + median hectares, p90, and a flag when it runs above norm.
- **Cause-mix panel** — the ~15 `GENERAL_CAUSE` categories, with a defined Human-vs-Lightning split, per region, null share shown.
- **Trend line** — annual fire count and hectares burned 2006–2025, with the 2012 cause break marked.
- **Signal / watch-list panel** — the "watch this area" list (definition in Business Rules).

**One stretch goal:**
- **Response-time view** — median lag from `REPORTED_DATE` → `FIRE_FIGHTING_START_DATE` by region (this exact pair; not dispatch→arrival), on the ~71% of fires with the second field, the 29% gap disclosed. Tells the analyst where suppression is slowest to start.

**Explicit refusals (and why):**
- **Suppression cost optimization** — no cost field exists in this data.
- **Real-time / current-season monitoring** — the data is a finalized annual record through 2025, not a live feed.
- **Fire-spread or risk forecasting** — out of scope for a historical benchmark; the predictive driver (fire-weather) is not in this data.
- **Per-fire mapping as the core view** — lat/long exists (possible stretch), but the decision is regional, not per-fire.

---

## 5 · Data — where it comes from, what one row is

**Source:** Alberta Forestry & Parks — Historical Wildfire Database 2006–2025. Open Government Licence – Alberta. Dictionary dated March 19, 2026.
**Connection:** CSV + official data-dictionary PDF connected in `knowledge/survey-data/` — read in full, never pasted.
**One row:** one wildfire incident inside the Forest Protection Area, ignition → extinguishment. 50 fields.
**Representativeness:** full FPA administrative record (**27,828 fires**); **excludes Mutual Aid fires outside the FPA** — so any provincial total is an FPA total, not all-Alberta.

**Load-bearing facts the agent must not guess (full list in `knowledge/data-cautions.md`):**
- Region = **first letter of `FIRE_NUMBER`** (10 forest areas: C Calgary, E Edson, G Grande Prairie, H High Level, L Lac La Biche, M Fort McMurray, P Peace River, R Rocky, S Slave Lake, W Whitecourt). **There is no region column.**
- `CURRENT_SIZE` is extreme right-skew → median + p90 + total, never a bare mean.
- `SIZE_CLASS` A–E is ordinal → never averaged.
- `GENERAL_CAUSE` has ~15 values, **not** "Lightning vs Human"; categories changed in 2012 (Agriculture & Government split out; Prescribed Fire only 2012–2016; Restart only until 2012).
- `ACTIVITY_CLASS` / `TRUE_CAUSE` are partially null → show the null share.
- **No cost field, no fire-weather-index field.** FPA-only coverage.

---

## 6 · Business Rules — the rules the numbers must always obey

These are domain/statistical rules, true regardless of how the agent is prompted.

- **The norm = 20-yr (2006–2025) MEAN annual value**, computed **separately for fire count and total hectares**. Use the mean, not the median — annual hectares is so skewed that a median-based norm explodes (see Spec Changelog #3).
- **Watch-list flag:** an area is flagged when its recent-3-years (2023–2025) mean annual value is **≥ 1.3×** its 20-yr-mean. Count and hectares are flagged independently and both shown — an area can be hot on area but not count, or vice-versa. **1.3× is the analyst-adjustable threshold** (see Human-in-the-Loop).
- **Human-vs-Lightning split** must be explicitly defined: "human-related" = every `GENERAL_CAUSE` except Lightning, Undetermined, Under Investigation, Restart. State the definition wherever the split is shown.
- **Size reporting:** always median + p90 + total hectares together; never a bare mean; never average `SIZE_CLASS`.
- **Cross-2012 cause trends** always carry the reclassification note.
- **Cause-detail views** (ACTIVITY_CLASS / TRUE_CAUSE) always display the null share.
- **FPA-only scope** stated wherever a total could be read as all-Alberta.

---

## 7 · Agent Behaviors — how the AI should work

**The agent decides on its own:**
- Chart type best fitting a distribution (bar, box, line, small multiples).
- The plain-language "read" under each regional comparison.
- How to compute and present the 20-year norms and the above-norm flags.

**Fixed in advance — no deviation:**
- Every number shows its N.
- Apply all Business Rules (§6) on every relevant view.
- **Never** use causal language ("causes" / "drives") for a statistical association — use "associated with."
- **Never** produce a dollar / cost figure (no cost field exists).
- **Never** produce a forecast ("next season will…") — this is a historical record.
- **Never** make a climate-attribution claim (no FWI / climate series here).
- **Never** present an FPA total as an all-Alberta total.
- **Never** take a side on the full-suppression-vs-managed-fire policy debate.

---

## 8 · Human in the Loop — what must be a human's call

**The human has the final word on:**
- The deployment / prevention recommendation. The dashboard surfaces the signal; the analyst makes and owns the call.
- Publishing or sharing any view — the analyst reviews first.

**Override logging rule (not optional):**
If the analyst overrides a flag or changes a norm threshold (e.g., declares a region comparable across the 2012 break, or moves the 1.3× threshold), the dashboard logs **who** changed it, **what** the original flag said, and **why**. No log, no change.

---

## Appendix A · Convergence — three candidates, criteria locked first

We locked the selection criteria **before** comparing concepts, so the data could not quietly choose for us.

**Criteria (locked first):** (1) real decision + owner, (2) data can honestly carry it, (3) decision-changing not just interesting, (4) buildable and evaluable in the week.

| # | Candidate | C1 user/decision | C2 data honest? | C3 changes a decision? | C4 week-buildable? | Verdict |
|---|-----------|------------------|-----------------|------------------------|--------------------|---------|
| A | **Pre-season regional benchmark** (chosen) | Planning analyst → where to place crews & prevention | ✅ 20-yr history is exactly what it is | ✅ shifts crew/prevention placement | ✅ aggregation + norms | **CHOSEN** |
| B | Real-time operational monitor | Duty officer → live dispatch | ❌ finalized annual record, **no live feed** | would, *if* data were live | ❌ no live source | Rejected on C2 |
| C | Per-fire cause-investigation explorer | Investigator → case review | ⚠️ `TRUE_CAUSE` only 52.5% filled | weak — case-level, not a planning lever | ✅ | Rejected on C1/C3 |

**Why B (the one we wrote down):** the most tempting clever build, but it fails C2 — the data is a finalized annual record through 2025, not a live feed, so there is no "right now" to monitor. **Why C:** a per-fire map is interesting but case-level, while the decision is regional, and its key field is half-null. We kept the user and decision fixed, locked the criteria, and let the data veto B — converging on **A**.

---

## Appendix B · Spec Changelog
*The spec is living: mocking the deliverable exposed gaps, folded back here rather than discovered in the Build.*

**2026-06-26 · Mocking the HTML skeleton exposed two underspecified panels** ("a panel you cannot fill is one you have not specified"):
1. **Watch-list signal was undefined** — which window, count or hectares, what ratio. **Folded back:** precise definition in §6 Business Rules.
2. **Response-time panel was unfillable** — the timestamp pair was not named. **Folded back:** pinned to `REPORTED_DATE → FIRE_FIGHTING_START_DATE`, 29% gap disclosed.

**2026-06-26 (later) · The richer interactive mock (`dashboard-mock.html`, wired to real numbers) exposed a third gap:**
3. **The norm baseline was wrong for hectares.** The signal had used the *median* annual value; computed live, annual hectares is so skewed that the median year burns almost nothing, so the ratio blew up (361×, 337×). **Folded back:** the norm is now the **20-yr mean annual**. With that fix the real signal tells the headline story — across 2023–2025, **9 of 10 areas burned ≥1.3× their 20-yr-mean hectares, but 0 of 10 exceeded norm on fire count.** The recent crisis is in *area burned*, not fire frequency — which is exactly why count and hectares are shown separately. *(This is the "one gap mocking exposed" for the Round 3 presentation.)*
