saveDir<-getwd()
dataDir<-paste(getwd(),"/Data/",sep="")
dir<-paste(dataDir,"/euronext/",sep="")
setwd(dir)


#loading and preprocessing data
fileName<-"BDM-Euronext-CAL-20100615.csv"
tradingDays <- read.csv(fileName,sep=";",header=TRUE)
tradingDays$Calendar.date<-as.Date(tradingDays$Calendar.date)
tradingDays$Trading.day.indicator<-as.logical(tradingDays$Trading.day.indicator)


setwd(saveDir)