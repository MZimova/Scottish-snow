# ---------------------------------------
# ---------------------------------------
# Snow hare data extraction
# ---------------------------------------
# ---------------------------------------

library(rgdal)
library(ncdf4)


# ---------------------------------------
# Data

pts = readOGR("/home/melville/Cloud/Michael/Projects/Snow_hares/data", "hare_sites")

nc.grid = readOGR("/home/melville/Cloud/Michael/Projects/Snow_hares/data", "MO_grid_ncdf")


# ---------------------------------------
# Points in polygon

cells = data.frame(id=pts$Name, over(pts, nc.grid)[c("X.x.", "X.y.")])
cells$id = gsub(" ", "_", cells$id)

# ---------------------------------------
# Extract from NetCDF

extractor = function(cell.x, cell.y){
   x = lapply(1960:2010, function(i){
      nc = nc_open(paste0("~/Downloads/temp/snow_results/full_", i, ".nc"))
      nc.swe = ncvar_get(nc, "SWE", start=c(cell.x, cell.y, 1), count=c(1, 1, -1))
      nc_close(nc)
      data.frame(date=seq.Date(
         as.Date(
            paste0(
               i, "-10-01")),
         by=1, length.out=length(nc.swe)
         ), round(nc.swe))
   })
   do.call("rbind.data.frame", x)
}

for(r in 1:nrow(cells)){
   swe = extractor(cells[r, 2], cells[r, 3])
   write.csv(swe, paste0("~/Downloads/temp/", cells[r, 1], ".csv"), row.names=F, quote=F)
}

