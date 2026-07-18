# UAV-DDT-HeritageBench

LaTeX source for: **UAV-Based Neural Reconstruction of Dong Drum Towers: A Multi-Case Benchmark for Conservation-Oriented Method Selection**

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
├── sections/                # Per-section .tex files
│   ├── abstract.tex
│   ├── introduction.tex
│   ├── research_background.tex
│   ├── study_objects.tex
│   ├── method.tex
│   ├── analysis.tex
│   └── conclusion.tex
├── figures/media                # All paper figures (PDF/EPS)
│   ├── image1.png
│   ├── image2.png
│   ├── image3.png
│   ├── ....
│   ├── image10.png
│   ├── ....
│   └── image14.png     
├── supplementary/           # Supplementary material
│   ├── .....mp4
│   ├── .....mp4
│   ├── .....mp4
│   └── requirementts.txt 
├── .gitignore               # Ignores LaTeX build artifacts
├── CITATION.cff             # Citation metadata
├── main.tex                 # Main LaTeX file
├── references.bib           # BibTeX references
├── Makefile                 # Build automation
├── CITATION.cff             # Citation metadata
├── IEEtarn.bst
├── IEEtrancls
├── LICENSE                  # CC-BY-4.0
├── Makefile
├── README.md
├── abstract.tex
├── main.tex                 # Main LaTeX file
└──references.bib
## Related Repositories

| Repository | Description |
|------------|-------------|
| [3DGS-Survey](https://github.com/autumn119/3DGS-Survey) | Project page (GitHub Pages) |
| [UAV-DDT-HeritageBench](https://github.com/autumn119/UAV-DDT-HeritageBench) | Benchmark code & data |

## Citation

```bibtex
@article{tao2026_dong_drum_tower,
  author  = {Tao, Jiaxing},
  title   = {UAV-Based Neural Reconstruction of Dong Drum Towers: A Multi-Case Benchmark for Conservation-Oriented Method Selection},
  journal = {IEEE Transactions on Visualization and Computer Graphics},
  year    = {2026},
  doi     = {10.5281/zenodo.20263999}
}
```

## License

This work is licensed under **CC-BY-4.0**. See [LICENSE](LICENSE) for details.
