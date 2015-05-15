#libelles

saveDir<-getwd()
dataDir<-paste(getwd(),"/Data/",sep="")
dir<-paste(dataDir,"abcbourse/",sep="")
setwd(dir)


#loading and preprocessing data
hier<-format(Sys.Date()-1,"%Y%m%d")

fileName<-paste("Cotations",hier,".txt",sep="")
cotations <- read.table(fileName,sep=";",header=FALSE)
names(cotations)<-c("ISIN","date","ouverture","haut","bas","cloture","volume")
cotations$date<-as.Date(cotations$date, "%d/%m/%y")

cotations










setwd(saveDir)