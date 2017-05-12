# R Script To Pull SPC Reports

# Function to check if particular package exists
is.installed <- function(mypkg){
  is.element(mypkg, installed.packages()[,1])
}

library(leaflet)
library(htmlwidgets)

# Function to grab the date from the user
readUserDate <- function() {
  d <- readline(prompt = "Enter a date in format YYMMDD: ")
  return(as.integer(d))
}

# Get the file from SPC
urlBase <- "http://www.spc.noaa.gov/climo/reports/"
urlTornadoSuffix <- as.character("_rpts_torn.csv")
urlHailSuffix <- as.character("_rpts_hail.csv")
urlWindSuffix <- as.character("_rpts_wind.csv")
urlSuffix <- c(urlTornadoSuffix, urlHailSuffix, urlWindSuffix)
userDate <- trimws(as.character(readUserDate(), which = "both"))

# Loop through the URLS and download the reports
for(rpts in urlSuffix) {
  download.file(paste(urlBase, userDate, rpts), paste(userDate, rpts))
}

# Read in hail file
spcHail <- read.table(paste(userDate, urlHailSuffix), header = TRUE, sep = ",")

# Do some work to transform file for map
spcHailCoords <- as.data.frame(cbind(lon=spcHail$Lon, lat=spcHail$Lat))
coordinates <- spcHailCoords$lon ~ spcHailCoords$lat

# Make the map
tileURL <- "https://api.mapbox.com/styles/v1/groovedrm/cj2l0hs94000u2rqmq1v0kwxi/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ3Jvb3ZlZHJtIiwiYSI6ImNpeXd5eDhiajAwMnkyd3J4ZXczeTh3ZWMifQ.FhscYf_rrnnmAwPbsj6Osg"
m <- leaflet(data = spcHailCoords) %>%
  addTiles(tileURL) %>%
  addCircles(radius = 1, weight = 5) 

saveWidget(m, file="map.html")

