#download
zipFileName<-"Euronext-CAL-20100615.csv.zip"
fileName<-"BDM-Euronext-CAL-20100615.csv"

download.file(paste(URL,zipFileName,sep=""),zipFileName)

#unzip
unzip(zipfile=zipFileName)