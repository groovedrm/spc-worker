# R Script To Pull SPC Reports

# Function to check if particular package exists
is.installed <- function(mypkg){
  is.element(mypkg, installed.packages()[,1])
}

# Function to grab the date from the user
readUserDate <- function() {
  d <- readline(prompt = "Enter a date in format YYMMDD: ")
  return(as.integer(d))
}

# Install Google Maps package if not already installed
if (!is.installed("plotGoogleMaps")){
  install.packages("plotGoogleMaps")
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

# Do some work to transform file for Google
spcHailCoords <- as.data.frame(cbind(lon=spcHail$Lon, lat=spcHail$Lat))
coordinates(spcHailCoords) <- ~lon+lat
proj4string(spcHailCoords) <- CRS("+init=epsg:4326")
a <- plotGoogleMaps(spcHailCoords)



