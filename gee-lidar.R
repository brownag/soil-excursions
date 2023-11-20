library(rgeedim)
# gd_authenticate(auth_mode = "notebook")
gd_initialize()
bb <- gd_bbox(xmin = -120, ymin=38, ymax=38.05, -119.95)

ee <- earthengine()
ee$data$listAssets(list(parent="USGS/3DEP/1m"))
gd_list_assets("USGS/3DEP/1m")
"USGS/3DEP/1m" |>
  # gd_image_from_id() |>
  gd_collection_from_name() |>
  gd_search(region = bb) -> x
gd_properties(x)

# gd_composite(resampling = "bilinear") |>
# gd_download(scale = 1,
#             region = bb,
#             filename = "D:/workspace/sANDREWbox/BlockDiagram/bidwell_park.tif",
#             overwrite = TRUE,
#             bands = list("elevation"),
#             crs = "EPSG:5070")
