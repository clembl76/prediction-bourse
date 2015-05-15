
source("C:/Users/Jawad/Documents/GitHub/prediction-bourse/init.R")

sample<-quotesPerDay[quotesPerDay$Name=="Daimler AG",]

g <- ggplot(sample,aes(Date,Close))
g+geom_line()+labs(title="Daimler Quotes per day",x="Date", y="Quote at Closing")
