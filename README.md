# UAV-DDT-HeritageBench

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20263999.svg)](https://doi.org/10.5281/zenodo.20263999)

LaTeX source for:

> **UAV-Based Neural Reconstruction of Dong Drum Towers: A Multi-Case Benchmark for Conservation-Oriented Method Selection**
> Tao Jiaxing — *IEEE Transactions on Visualization and Computer Graphics*, 2026

This repository provides the full LaTeX manuscript, figures, and supplementary materials for a benchmark study evaluating UAV-based neural 3D reconstruction methods (NeRF / 3DGS variants) applied to Dong minority Drum Tower heritage sites in China.

## Prerequisites

- TeX Live 2021+ or MiKTeX (with `pdflatex`, `bibtex`)
- `make` (Linux/macOS) or a LaTeX IDE (Overleaf, TeXstudio) on Windows

## Build

```bash
make            # compile PDF (pdflatex + bibtex)
make clean      # remove auxiliary files
make cleanall   # remove all generated files including PDF
make view       # compile and open PDF (macOS)
```

Or manually:
```bash
pdflatex main
bibtex main
pdflatex main
pdflatex main
```

## Repository Structure

```
UAV-DDT-HeritageBench/
├── sections/               # Per-section .tex files
│   ├── abstract.tex
│   ├── introduction.tex
│   ├── research_background.tex
│   ├── study_objects.tex
│   ├── method.tex
│   ├── analysis.tex
│   └── conclusion.tex
├── figures/media/          # All paper figures (image1.png … image14.png)
├── supplementary/          # Supplementary videos & data
│   ├── *.mp4               # Reconstruction result videos
│   └── requirements.txt    # Environment for reproducing results
├── main.tex                # Main LaTeX entry file
├── references.bib          # BibTeX references
├── IEEEtran.cls            # IEEE journal document class
├── IEEEtran.bst            # IEEE BibTeX style
├── Makefile                # Build automation
├── CITATION.cff            # Citation metadata
├── .gitignore              # Ignores LaTeX build artifacts
├── LICENSE                 # CC-BY-4.0
└── README.md
```

## Related Repositories

| Repository | Description |
|------------|-------------|
| [3DGS-Survey](https://github.com/autumn119/3DGS-Survey) | Project page (GitHub Pages) |
| [UAV-DDT-HeritageBench](https://github.com/autumn119/UAV-DDT-HeritageBench) | Benchmark code & data (this repo) |

## Citation

If you use this work, please cite:

```bibtex
@article{tao2026_dong_drum_tower,
  author  = {Tao, Jiaxing},
  title   = {UAV-Based Neural Reconstruction of Dong Drum Towers: A Multi-Case Benchmark for Conservation-Oriented Method Selection},
  journal = {IEEE Transactions on Visualization and Computer Graphics},
  year    = {2026}
}
```

Archived dataset: [10.5281/zenodo.20263999](https://doi.org/10.5281/zenodo.20263999)

## License

This work is licensed under **CC-BY-4.0**. See [LICENSE](LICENSE) for details.


