saveDir<-getwd()
dataDir<-paste(getwd(),"/Data/",sep="")
dir<-paste(dataDir,"/euronext/",sep="")
setwd(dir)

# FTP de EuroNext
URL<-"ftp://ftp.nyxdata.com/Historical Data Samples/Euronext NextHistory Cash/"

## ######################################################################################################
## Jours où le marché est ouvert
## ######################################################################################################

#download
zipFileName<-"Euronext-CAL-20100615.csv.zip"
fileName<-"BDM-Euronext-CAL-20100615.csv"

download.file(paste(URL,zipFileName,sep=""),zipFileName)

#unzip
unzip(zipfile=zipFileName)
file.remove(zipFileName)

setwd(saveDir)
