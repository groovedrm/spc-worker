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

# Read in files
spcTornado <- read.table(paste(userDate, urlTornadoSuffix), header = TRUE, sep = ",")
spcHail <- read.table(paste(userDate, urlHailSuffix), header = TRUE, sep = ",")
spcWind <- read.table(paste(userDate, urlWindSuffix), header = TRUE, sep = ",")

# Do some work to transform file for map
spcTorCoords <- as.data.frame(cbind("Torn", lon=spcTornado$Lon, lat=spcTornado$Lat))
spcHailCoords <- as.data.frame(cbind("Hail", lon=spcHail$Lon, lat=spcHail$Lat))
spcWindCoords <- as.data.frame(cbind("Wind", lon=spcWind$Lon, lat=spcWind$Lat))
spcAllCoords <- as.data.frame(rbind(spcTorCoords,spcHailCoords,spcWindCoords))
names(spcAllCoords) <- c("type","lon","lat")

# Make the map
reportTypes = as.character(unique(spcAllCoords$type))
tileURL <- "https://api.mapbox.com/styles/v1/groovedrm/cj2l0hs94000u2rqmq1v0kwxi/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ3Jvb3ZlZHJtIiwiYSI6ImNpeXd5eDhiajAwMnkyd3J4ZXczeTh3ZWMifQ.FhscYf_rrnnmAwPbsj6Osg"
m <- leaflet(spcAllCoords) %>% addTiles(tileURL)
  for(t in reportTypes) {
    d = spcAllCoords[spcAllCoords$type == t, ]
    m = m %>% addCircles(lng = as.numeric(d$lon), lat = as.numeric(d$lat),
                           color = t,
                           group = t)
  }
  m %>% addLayersControl(overlayGroups = reportTypes)

saveWidget(m, file="map_test.html")

