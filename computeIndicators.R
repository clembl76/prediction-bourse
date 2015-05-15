source("C:/Users/Jawad/Documents/GitHub/prediction-bourse/init.R")



# add dates aggregations
quotesPerDay$year<-as.integer(format(as.POSIXct(quotesPerDay$Date), "%Y"))
quotesPerDay$weekInYear<-as.integer(format(as.POSIXct(quotesPerDay$Date), "%U"))
quotesPerDay$yearWeek<-format(as.POSIXct(quotesPerDay$Date), "%Y-%U")
quotesPerDay$dayInWeek<-as.factor(weekdays(quotesPerDay$Date))
quotesPerDay$dayInYear<-as.integer(format(as.POSIXct(quotesPerDay$Date), "%j"))
quotesPerDay$dayInMonth<-as.integer(format(as.POSIXct(quotesPerDay$Date), "%d"))

# max - min de la valeur, en absolu et %
quotesPerDay$varInDay<-quotesPerDay$High-quotesPerDay$Low
quotesPerDay$varInDay_p<-round(100*quotesPerDay$varInDay/quotesPerDay$Open,2)

# max - min de la valeur, moyenne sur une semaine glissante, en absolu et %
thisDayInYear<-as.integer(format(as.POSIXct(Sys.Date()), "%j"))
thisYear<-as.integer(format(as.POSIXct(Sys.Date()), "%Y"))

s<-quotesPerDay[quotesPerDay$year==thisYear & quotesPerDay$dayInYear>thisDayInYear-8,]
w<-aggregate(s$varInDay_p,by=list(s$Name),FUN=mean,na.rm=TRUE)
names(w)<-c("Name","varInDay_p_avg1w")
