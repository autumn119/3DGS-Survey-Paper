# UAV-DDT-HeritageBench

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20263999.svg)](https://doi.org/10.5281/zenodo.20263999)

Manuscript, benchmark code, and dataset for:

> **UAV-Based Neural Reconstruction of Dong Drum Towers: A Multi-Case Benchmark for Conservation-Oriented Method Selection**
> Tao Jiaxing — *IEEE Transactions on Visualization and Computer Graphics*, 2026

This repository provides the **manuscript, benchmark code, and dataset** for a study evaluating UAV-based neural 3D reconstruction methods applied to Dong minority Drum Tower heritage sites in China. Four methods are compared under a unified, fairness-controlled protocol, and results are interpreted for conservation-oriented method selection.

## Overview

**Methods benchmarked** (4): NeRF, 2DGS, 3DGS, and Instant-NGP (INGP).

**Pipeline** (6 stages): UAV image acquisition → corpus construction → camera pose estimation & sparse reconstruction (COLMAP) → neural rendering/reconstruction (4 methods) → quantitative & qualitative evaluation → conservation-oriented interpretation.

**Evaluation metrics**:

| Metric | Direction | Interpretation |
|--------|-----------|----------------|
| PSNR | Higher is better | Pixel-level reconstruction fidelity |
| SSIM | Higher is better | Structural & visual consistency |
| LPIPS | Lower is better | Perceptual similarity & texture realism |
| Training time | Lower is better | Computational efficiency |
| Rendering speed (FPS) | Higher is better | Real-time visualization capability |

**Fairness control**: identical UAV image set per scene (resized to 1920×1080), shared SfM camera poses, common LLFF-style train/test split, same workstation, and default/recommended parameters per method.

## Prerequisites

**To build the paper:**
- TeX Live 2021+ or MiKTeX (with `pdflatex`, `bibtex`)
- `make` (Linux/macOS) or a LaTeX IDE (Overleaf, TeXstudio) on Windows

**To run the benchmark:**
- CUDA-capable GPU (experiments used an NVIDIA RTX 4090, 24 GB)
- Python 3.8+, PyTorch, TensorFlow 2.x (for NeRF)
- COLMAP 3.14.0 with CUDA
- See `code/requirements.txt` for the full Python environment

## Build the Paper

```bash
cd paper
make            # compile PDF (pdflatex + bibtex)
make clean      # remove auxiliary files
make cleanall   # remove all generated files including PDF
make view       # compile and open PDF (Windows / macOS / Linux)
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
├── paper/                  # LaTeX manuscript
│   ├── sections/           # Per-section .tex files
│   │   ├── abstract.tex
│   │   ├── introduction.tex
│   │   ├── research_background.tex
│   │   ├── study_objects.tex
│   │   ├── method.tex
│   │   ├── analysis.tex
│   │   └── conclusion.tex
├── figures/media/      # All paper figures (image1.png … image14.png)
├── main.tex            # Main LaTeX entry file
├── references.bib      # BibTeX references
├── IEEEtran.cls        # IEEE journal document class
├── IEEEtran.bst        # IEEE BibTeX style
├── Makefile            # Build automation
│
├── code/                   # Benchmark code
│   ├── preprocess/         # Image screening & resize to 1920×1080
│   ├── colmap/             # SfM pose estimation scripts (COLMAP 3.14.0)
│   ├── methods/            # Per-method training / rendering wrappers
│   │   ├── nerf/           # nerf-pytorch style
│   │   ├── 2dgs/           # hbb1/2d-gaussian-splatting
│   │   ├── 3dgs/           # graphdeco-inria/gaussian-splatting
│   │   └── ingp/           # Instant-NGP v2.0dev
│   ├── eval/               # PSNR / SSIM / LPIPS + timing metrics
│   └── requirements.txt    # Python environment
│
├── data/                   # Dataset (see Data Availability)
│   ├── <scene>/images/     # UAV images per drum tower scene
│   ├── <scene>/sparse/     # COLMAP sparse reconstruction
│   └── splits/             # Train/test image lists (LLFF-style)
│
├── supplementary/          # Reconstruction result videos (*.mp4)
├── CITATION.cff            # Citation metadata
├── .gitignore              # Ignores build artifacts & large data
├── LICENSE                 # CC-BY-4.0
└── README.md
```

## Reproducing the Benchmark

**Hardware/software used**: NVIDIA RTX 4090 (24 GB), COLMAP 3.14.0 (CUDA), PyTorch (2DGS/3DGS), TensorFlow 2.x (NeRF), Instant-NGP v2.0dev.

**Scenes** (4): `chaoli` · `zeli` · `chongjiang` · `zengchong`

```bash
# 1. Set up Python environment
cd code
pip install -r requirements.txt

# 2. Preprocess: blur screening + resize to 1920×1080
#    Run for one scene or all at once
python preprocess/prepare_images.py --scene chaoli
python preprocess/prepare_images.py --scene all

# 3. Camera pose estimation with COLMAP (shared across all 4 methods)
bash colmap/run_sfm.sh chaoli     # or: bash colmap/run_sfm.sh all

# 4. Train each method (30k iters for 3DGS/2DGS; 200k for NeRF; 35k for INGP)
bash methods/3dgs/train.sh chaoli
bash methods/2dgs/train.sh chaoli
bash methods/nerf/train.sh  chaoli
bash methods/ingp/train.sh  chaoli

# 5. Evaluate — PSNR / SSIM / LPIPS across all scenes and methods
python eval/metrics.py --scene all --method all
# Results saved to data/results_summary.csv
```

> **Note on Chaoli**: no fully independent held-out test view is available under the current LLFF split; its reported metrics are reference values, not independently validated test-set scores.

## Data Availability

The UAV image corpus, COLMAP sparse reconstructions, and train/test splits are archived on Zenodo (see [Citation](#citation)). Download and extract into `data/` following the structure above. Large binaries (raw images, checkpoints) are excluded from git via `.gitignore`.

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


