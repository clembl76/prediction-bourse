
source("C:/Users/Jawad/Documents/GitHub/prediction-bourse/init.R")

name<-"Daimler AG"
name<-"BNP Paribas SA"
sample<-quotesPerDay[quotesPerDay$Name==name,]
sample<-sample[1:365*5,]

# Quotes per day
g <- ggplot(sample,aes(Date,Close))
g+geom_line()+labs(title=paste(name," Quotes per day",sep=""),x="Date", y="Quote at Closing")

g <- ggplot(sample, aes(Date)) 
g+geom_line(aes(y = Close, colour = "Close")) + geom_line(aes(y = Open, colour = "Open"))

g <- ggplot(sample, aes(Date)) 
g+geom_line(aes(y = High, colour = "High")) + geom_line(aes(y = Low, colour = "Low"))

# Volatilité
g <- ggplot(sample,aes(Date,varInDay_p))
g+geom_point()+geom_smooth()

g <- ggplot(vol_month,aes(Month,varInDay_p_avg1M))
g+geom_line()

g <- ggplot(vol_yearmonth,aes(yearMonth,varInDay_p_avg1YM,group = 1))
g+geom_point()+geom_smooth()


#essai rolling average
plot(cbind(sample$Date, rollmean(sample$Close, 50)), screen = 1, col = 1:2) 

# Quotes var % per day
g <- ggplot(sample,aes(Date,varInDay_p))
g+geom_line()+geom_smooth()+labs(title=paste(name," varInDay_p per day",sep=""))

# Quotes var % per week
w<-aggregate(sample$varInDay_p,by=list(sample$yearWeek),FUN=mean,na.rm=TRUE)
names(w)<-c("yearWeek","varInDay_p")
g <- ggplot(w,aes(yearWeek,varInDay_p,group=1))
g+geom_line()+geom_smooth()+labs(title=paste(name," varInDay_p per week",sep=""))
