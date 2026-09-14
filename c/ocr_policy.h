/* EPFL ME-213 Binairo 2026. AI-assisted implementation by Codex.
 * Team author names: to be supplied before submission; see docs report.
 * Contract and provisional choices: docs/INTERFACE_CONTRACT.md. */
#ifndef BINAiro_OCR_POLICY_H
#define BINAiro_OCR_POLICY_H

/* Provisional assignment decisions: see docs/INTERFACE_CONTRACT.md.
 * Change only these definitions if the professor resolves either ambiguity.
 * P26 p19 gives 10..100 as an example; 256 accommodates the supplied grids.
 */
#define OCR_MIN_DIMENSION 10u
#define OCR_MAX_DIMENSION 256u

/* P26 p18: choose score - threshold. Set to 0 for raw-score choice (p10).
 * Eligibility remains score >= threshold in either mode. Exact ties prefer
 * the larger raw score, then digit 0. Empty detection always uses strict >.
 */
#ifndef OCR_SELECT_BY_MARGIN
#define OCR_SELECT_BY_MARGIN 1
#endif
#if OCR_SELECT_BY_MARGIN != 0 && OCR_SELECT_BY_MARGIN != 1
#error OCR_SELECT_BY_MARGIN must be 0 or 1
#endif

#endif
