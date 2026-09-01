# GEOG70581 — Hydrological modelling practical (Eskdale)
# =======================================================
# DEM-based drainage analysis of the Eskdale catchment with WhiteboxTools:
#
#   fill depressions -> slope -> D8 flow pointer -> specific contributing
#   area under three flow-routing algorithms (D8, FD8, D-Infinity),
#   visualised with ggplot2.
#
# Input data (see README): data/practical_1/dem_10m.tif
# Outputs are written to output/practical_1/
#
# Requires R packages: whitebox, raster, sf, ggplot2, ggspatial, cowplot, here

library(here)
library(whitebox)
library(raster)
library(sf)
library(ggplot2)
library(ggspatial)
library(cowplot)

# ---------------------------------------------------------------------------
# 1. Depression filling
# ---------------------------------------------------------------------------

# Single depression-filling pass on the 10 m DEM
dem <- here("data", "practical_1", "dem_10m.tif")
wbt_fill_depressions(dem, here("output", "practical_1", "dem_10m_fill.tif"))

# Difference between the filled DEM and the original: where and how deep
# depressions were modified
wbt_subtract(here("output", "practical_1", "dem_10m_fill.tif"),
             dem,
             here("output", "practical_1", "dem_10m_fill_difference.tif"))

eskdale_fill <- raster(here("output", "practical_1", "dem_10m_fill_difference.tif"))
min_fill <- min(values(eskdale_fill)[values(eskdale_fill) > 0], na.rm = TRUE)
max_fill <- max(values(eskdale_fill), na.rm = TRUE)

g_fill <- ggplot() +
  layer_spatial(eskdale_fill, aes(fill = after_stat(band1))) +
  theme_classic() +
  labs(fill = "Elevation difference (m)", x = "Easting", y = "Northing") +
  scale_fill_continuous(type = "viridis", na.value = NA, limits = c(min_fill, max_fill))
g_fill

# ---------------------------------------------------------------------------
# 2. Slope
# ---------------------------------------------------------------------------

wbt_slope(dem, here("output", "practical_1", "dem_10m_slope.tif"))

eskdale_slope <- raster(here("output", "practical_1", "dem_10m_slope.tif"))
g_slope <- ggplot() +
  layer_spatial(eskdale_slope) +
  theme_classic() +
  labs(fill = "Slope angle", x = "Easting", y = "Northing") +
  scale_fill_continuous(type = "viridis", na.value = NA)
g_slope

# ---------------------------------------------------------------------------
# 3. D8 flow pointer
# ---------------------------------------------------------------------------

wbt_d8_pointer(dem, here("output", "practical_1", "dem_10m_pointers.tif"))

eskdale_pointers <- raster(here("output", "practical_1", "dem_10m_pointers.tif"))

# Manual colours following the "RdYlBu" palette for the eight pointer codes
colours <- c("1" = "#D73027", "2" = "#F46D43", "4" = "#FDAE61",
             "8" = "#FEE090", "16" = "#E0F3F8", "32" = "#ABD9E9",
             "64" = "#74ADD1", "128" = "#4575B4")

g_pointers <- ggplot() +
  layer_spatial(eskdale_pointers, aes(fill = factor(after_stat(band1)))) +
  theme_classic() +
  labs(fill = "Pointer value", x = "Easting", y = "Northing") +
  scale_fill_manual(values = colours, na.value = NA)
g_pointers

# ---------------------------------------------------------------------------
# 4. Specific contributing area under three flow-routing algorithms
# ---------------------------------------------------------------------------

# Breach then fill the DEM before routing (avoids artificial pits)
wbt_fill_depressions(dem, here("output", "practical_1", "dem_10m_fill.tif"))
wbt_breach_depressions(dem, here("output", "practical_1", "dem_10m_breach.tif"))
wbt_d8_pointer(here("output", "practical_1", "dem_10m_fill.tif"),
               here("output", "practical_1", "dem_10m_D8_pointer.tif"))

# D8: single flow direction to the steepest neighbour
wbt_d8_flow_accumulation(here("output", "practical_1", "dem_10m_fill.tif"),
                         here("output", "practical_1", "dem_10m_flow_accumulation.tif"),
                         out_type = "specific contributing area",
                         log = "TRUE")

# FD8: multiple flow directions with an exponent of 1.1
wbt_fd8_flow_accumulation(here("output", "practical_1", "dem_10m_fill.tif"),
                          here("output", "practical_1", "dem_10m_flow_accumulation_fd8.tif"),
                          out_type = "specific contributing area",
                          log = "TRUE",
                          exponent = 1.1)

# D-Infinity: flow partitioned by the steepest gradient direction
wbt_d_inf_flow_accumulation(here("output", "practical_1", "dem_10m_fill.tif"),
                            here("output", "practical_1", "dem_10m_flow_accumulation_d_inf.tif"),
                            out_type = "specific contributing area",
                            log = "TRUE")

# ---------------------------------------------------------------------------
# 5. Visualisation
# ---------------------------------------------------------------------------

d8 <- raster(here("output", "practical_1", "dem_10m_flow_accumulation.tif"))
fd8 <- raster(here("output", "practical_1", "dem_10m_flow_accumulation_fd8.tif"))
d_inf <- raster(here("output", "practical_1", "dem_10m_flow_accumulation_d_inf.tif"))

plot_flow <- function(r, title) {
  ggplot() +
    layer_spatial(r, aes(fill = after_stat(band1))) +
    theme_classic() +
    labs(fill = "Log SCA", x = "Easting", y = "Northing", title = title) +
    scale_fill_continuous(type = "viridis", na.value = NA) +
    theme(plot.title = element_text(hjust = 0.5))
}

p_d8 <- plot_flow(d8, "D8")
p_fd8 <- plot_flow(fd8, "FD8")
p_dinf <- plot_flow(d_inf, "D-Infinity")

# Combine the three panels
combined_plot <- p_d8 + p_fd8 + p_dinf
combined_plot
