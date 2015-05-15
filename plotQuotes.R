
source("C:/Users/Jawad/Documents/GitHub/prediction-bourse/init.R")

name<-"Daimler AG"
name<-"BNP Paribas SA"
sample<-quotesPerDay[quotesPerDay$Name==name,]
sample<-sample[1:365,]

# Quotes per day
g <- ggplot(sample,aes(Date,Close))
g+geom_line()+geom_smooth()+labs(title=paste(name," Quotes per day",sep=""),x="Date", y="Quote at Closing")

# Quotes var % per day
g <- ggplot(sample,aes(Date,varInDay_p))
g+geom_line()+geom_smooth()+labs(title=paste(name," varInDay_p per day",sep=""))

# Quotes var % per week
w<-aggregate(sample$varInDay_p,by=list(sample$yearWeek),FUN=mean,na.rm=TRUE)
names(w)<-c("yearWeek","varInDay_p")
g <- ggplot(w,aes(yearWeek,varInDay_p,group=1))
g+geom_line()+geom_smooth()+labs(title=paste(name," varInDay_p per week",sep=""))
