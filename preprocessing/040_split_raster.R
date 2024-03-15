#'@name 040_split_raster.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 28.06.2023
#'@description filter corine dater to forest area and rasterize


# 1 - prepare forest model ####
#-----------------------------#

r=terra::rast("02_data/02_variables/05_fragstats_forest_model/7TS_SentinelLidar_pred.tif")

border = sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
border=sf::st_buffer(border, 3050)
border=sf::st_transform(border, terra::crs(r))
r=terra::crop(r, border)

# create background values for fragstats
r=terra::subst(r, NA, 999)
r=terra::mask(r, border)

#terra::writeRaster(r, "02_data/02_variables/03_corine/data/corine_south2.tif", overwrite=T)


# 2 - crop forest model ####
#--------------------------#

df=data.frame(xmin=1:5, xmax=1:5, ymin=1:5, ymax=1:5)

e=terra::ext(r)

distanceX=((e$xmax-e$xmin)/2)#+3050
distanceY=((e$ymax-e$ymin)/2)#+3050

# first chunk
df[1,]$xmin <- e$xmin
df[1,]$ymin <- e$ymin
df[1,]$xmax <- e$xmin+distanceX
df[1,]$ymax <- e$ymin+distanceY

# second chunk 2
df[2,]$xmin <- df$xmax[1]
df[2,]$ymin <- df$ymax[1]
df[2,]$xmax <- df$xmax[1]+distanceX
df[2,]$ymax <- df$ymax[1]+distanceY


df[3,]$xmin <- df$xmin[1]
df[3,]$ymin <- df$ymax[1]
df[3,]$xmax <- df$xmax[1]
df[3,]$ymax <- df$ymax[1]+distanceY


# chunk 4
df[4,]$xmin <- df$xmax[1]
df[4,]$ymin <- -546105
df[4,]$xmax <- e$xmax
df[4,]$ymax <- df$ymax[1]

# chunk 5
df[5,]$xmin <- df$xmax[1]
df[5,]$ymin <- e$ymin
df[5,]$xmax <- e$xmax
df[5,]$ymax <- -546105

# create buffer
df2=df
df2$xmin=df2$xmin-3100
df2$ymin=df2$ymin-3100
df2$xmax=df2$xmax+3100
df2$ymax=df2$ymax+3100

df=df2

for (i in 1:nrow(df)){
  r1=terra::crop(r,terra::ext(df$xmin[i], df$xmax[i], df$ymin[i], df$ymax[i]))
    terra::writeRaster(r1, sprintf("02_data/02_variables/05_fragstats_forest_model/chunks/chunk%s.tif",i), overwrite=T)
  
}
