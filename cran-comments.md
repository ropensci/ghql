## Maintainer change

This update comes from the new maintainer, Christopher Smolen <chrispbsmolen@gmail.com>, replacing Mark Padgham <mark.padgham@email.com>, who remains an author. The change was arranged with rOpenSci, which hosts the package (https://github.com/ropensci/ghql/issues/40). Mark was told by email on 20 Nov 2026 that CRAN will ask him to confirm.

## R CMD check results

0 errors | 0 warnings | 2 notes

* The new maintainer note (see above).
* "Skipping checking HTML validation: 'tidy' doesn't look like recent enough HTML Tidy", from the local check machine.

Checked locally with R CMD check --as-cran on macOS (aarch64), R 4.6.1, and on win-builder with R-devel (2026-11-17 r90926 ucrt): Status 1 NOTE, the new maintainer note only.

## Reverse dependencies

All three reverse dependencies pass R CMD check with this version (Status: OK): ARDECO 2.2.3, otargen 2.0.1, Rnumerai 3.0.1.
