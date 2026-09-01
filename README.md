# GEOG70581 — Hydrological modelling (Eskdale DEM analysis)

R script from the University of Manchester MSc module **GEOG70581
Environmental Monitoring, Modelling and Reconstruction** (Practical 1:
Eskdale). It runs a DEM-based drainage analysis of the Eskdale catchment
using the **WhiteboxTools** engine from R.

## What the script does

1. **Depression filling** — single-pass fill, plus a map of where/how deep
   the DEM was modified.
2. **Slope** — gradient of the 10 m DEM.
3. **D8 flow pointer** — the eight-direction flow direction grid.
4. **Specific contributing area** — under three flow-routing algorithms:
   * **D8** — single flow direction to the steepest neighbour
   * **FD8** — multiple flow directions (exponent 1.1)
   * **D-Infinity** — flow partitioned by the steepest gradient direction
5. **Visualisation** — each result is mapped with `ggplot2`; the three
   contributing-area maps are combined into one panel.

## Requirements

```r
install.packages(c("whitebox", "raster", "sf", "ggplot2", "ggspatial",
                   "cowplot", "here"))
whitebox::install_whitebox()
```

## Running

The script expects the course data in `data/` and writes outputs to
`output/practical_1/`:

```
data/practical_1/dem_10m.tif      # input DEM (not included; see below)
output/practical_1/               # created at runtime
```

```r
source("eskdale_hydrology.R")
```

## Data

* `data/flow_data.csv` — a small example dataset kept for reference.
* The 10 m DEM (`dem_10m.tif`) is course material from GEOG70581 and is **not
  included** in this repository; place it in `data/practical_1/` to run the
  script.

## License

MIT. See `LICENSE`.
