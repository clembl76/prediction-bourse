 source("C:/Users/Jawad/Documents/GitHub/prediction-bourse/init.R")

# #############################################################################################"
# Set Directory
# #############################################################################################"

saveDir<-getwd()
dataDir<-paste(getwd(),"/Data/",sep="")
dir<-paste(dataDir,"yahooFinance/",sep="")
setwd(dir)
rm(dir,dataDir)
# #############################################################################################"
# Tickers names
# List of companies for nasdaq and nyse
#URL<-"http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download"
#URL<-"http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download"
#URL<-"http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=cac40&render=download"

#destFile<-"companylist.csv"
#download.file(URL,destFile)
# #############################################################################################"
# Tickers names
# List of companies for Cac40 (^FCHI) -Paris
# List of companies for Dax (^GDAXI)
stocks<-c("GDAXI","FCHI")
rm(tickers)
tickers<-data.frame(matrix(ncol = 3, nrow = 0))
names(tickers)<-c("Symbol","Name","Stock")
tickers_list<-""

for (stock in stocks){

#stock<-"GDAXI"
url<-paste("http://finance.yahoo.com/q/cp?s=%5E",stock,sep="")
script <- getURL(url)
doc <- htmlParse(script)

#get column values
li <- getNodeSet(doc, "//td[@class='yfnc_tabledata1']") 
rm(tickers_tmp)
j<-length(li)/5
tickers_tmp<-data.frame(matrix(ncol = 3, nrow = j))
names(tickers_tmp)<-c("Symbol","Name","Stock")


for(i in 1:j){
  # code
  tickers_tmp[i,1]<-xmlValue(li[[1+5*(i-1)]][[1]][[1]][[1]])
  # nom
  tickers_tmp[i,2]<-xmlValue(li[[2+5*(i-1)]][[1]])
  # stock
  tickers_tmp[i,3]<-stock
  # je ne récupère pas les autres valeurs
  tickers_list<-paste(tickers_list,tickers_tmp[i,1],sep=",")
}
tickers<-rbind(tickers,tickers_tmp)
}
tickers_list<-substring(tickers_list, 2)
rm(url,script,doc,li,tickers_tmp,i,j,stocks,stock)

# #############################################################################################"

# voir la documentation pour construire les urls ici
# http://www.canbike.org/information-technology/yahoo-finance-url-download-to-a-csv-file.html

#http://download.finance.yahoo.com/d/quotes.csv?s=IBM&f=nl1r&e=.csv
#http://download.finance.yahoo.com/d/quotes.csv?s=IBM&f=sl1d1t1c1ohgv&e=.csv

# #############################################################################################"
# all tags are in the tag.csv file
tags<-read.csv("tags.csv",sep=";",header=TRUE)

# concatener tous les tags
# aa2a5bb2b3b4b6cc1c3c4c6c8dd1d2ee1e7e8e9f0f6gg1g3g4g5g6hii5jj1j2j3j4j5j6kk1k2k3k4k5ll1l2l3mm2m3m4m5m6m7m8nn4opp1p2p5p6qrr1r2r5r6r7ss1s6s7t1t6t7t8vv1v7ww1w4xy
names<-c('Ask','Average Daily Volume','Ask Size','Bid','Ask Realtime','Bid Realtime','Book Value','Bid Size','Change & Percent Change','Change','Commission','Currency','Change Realtime','After Hours Change Realtime','Dividend Share','Last Trade Date','Trade Date','Earnings Share','Error Indication returned for symbol changed   invalid','EPS Estimate Current Year','EPS Estimate Next Year','EPS Estimate Next Quarter','Trade Links Additional','Float Shares','Day s Low','Holdings Gain Percent','Annualized Gain','Holdings Gain','Holdings Gain Percent Realtime','Holdings Gain Realtime','Day s High','More Info','Order Book Realtime','52week Low','Market Capitalization','Shares Outstanding','Market Cap Realtime','EBITDA','Change From 52week Low','Percent Change From 52week Low','52week High','Last Trade Realtime With Time','Change Percent Realtime','Last Trade Size','Change From 52week High','Percent Change From 52week High','Last Trade With Time','Last Trade Price Only','High Limit','Low Limit','Day s Range','Day s Range Realtime','50day Moving Average','200day Moving Average','Change From 200day Moving Average','Percent Change From 200day Moving Average','Change From 50day Moving Average','Percent Change From 50day Moving Average','Name','Notes','Open','Previous Close','Price Paid','Change in Percent','Price Sales','Price Book','ExDividend Date','P E Ratio','Dividend Pay Date','P E Ratio Realtime','PEG Ratio','Price EPS Estimate Current Year','Price EPS Estimate Next Year','Symbol','Shares Owned','Revenue','Short Ratio','Last Trade Time','Trade Links','Ticker Trend','1 yr Target Price','Volume','Holdings Value','Holdings Value Realtime','52week Range','Day s Value Change','Day s Value Change Realtime','Stock Exchange','Dividend Yield')

# #############################################################################################"

tickerSymbols<-tickers_list
tagsToRead<-"aa2a5bb2b3b4b6cc1c3c4c6c8dd1d2ee1e7e8e9f0f6gg1g3g4g5g6hii5jj1j2j3j4j5j6kk1k2k3k4k5ll1l2l3mm2m3m4m5m6m7m8nn4opp1p2p5p6qrr1r2r5r6r7ss1s6s7t1t6t7t8vv1v7ww1w4xy"

# #############################################################################################"


URL<-paste("http://download.finance.yahoo.com/d/quotes.csv?s=",tickerSymbols,"&f=",tagsToRead,"&e=.csv",sep="")
destFile<-"quotes.csv"
download.file(URL,destFile)

# #############################################################################################"
# read downloaded file
# avec ça, j'ai les cotations du CAC40 à l'instant t
# J'ai l'Open du jour et le PreviousClose

quotes_now<-read.csv(destFile,sep=",",header=FALSE)
names(quotes_now)<-make.names(names,unique = FALSE, allow_ = TRUE)

# reste à faire: passer dans les bons formats
# par ex tous les champs qui ont "Date" dans leur nom
#quotes_now$date<-as.Date(quotes_now$date, "%d/%m/%y")

# #############################################################################################"
# Historical data for one value per day since 1984
# url directe de téléchargement pour une valeur
# url<-"http://real-chart.finance.yahoo.com/table.csv?s=AC.PA&d=4&e=15&f=2015&g=d&a=0&b=3&c=2000&ignore=.csv"

quotesPerDay<-data.frame(Date=as.Date(character(0)),Open=numeric(0),High=numeric(0),Low=numeric(0),Close=numeric(0),Volume=integer(0),Adj.Close=numeric(0),Symbol=character(0))

#begin<-Sys.Date()-365*10
#begin<-format(begin,"&a=%m&b=%d&c=%Y")
begin<-"&a=0&b=1&c=1984"
end<-Sys.Date()
end<-format(end,"&d=%m&e=%d&f=%Y")

for (i in 1:nrow(tickers)){
  
  ticker<-tickers[i,1]
  url<-paste("http://real-chart.finance.yahoo.com/table.csv?s=",ticker,begin,"&g=d",end,"&ignore=.csv",sep="")
  
  # Download
  destFile<-paste("quotesPerDay_",ticker,".csv",sep="")
  download.file(url,destFile)
  
  # Read file
  rm(quotesPerDay_tmp)
  quotesPerDay_tmp<-read.csv(destFile,sep=",",header=TRUE)
  quotesPerDay_tmp$Date<-as.Date(quotesPerDay_tmp$Date)
  quotesPerDay_tmp$Symbol<-ticker
  
  # Add to all values' file
  quotesPerDay<-rbind(quotesPerDay,quotesPerDay_tmp)
  
  if(file.exists(destFile)){file.remove(destFile)}
  
}
quotesPerDay<-merge(tickers,quotesPerDay,by="Symbol")
quotesPerDay$Symbol<-as.factor(quotesPerDay$Symbol)
quotesPerDay$Name<-as.factor(quotesPerDay$Name)
quotesPerDay$Stock<-as.factor(quotesPerDay$Stock)
str(quotesPerDay)

rm(destFile,begin,end,i,URL,url,quotesPerDay_tmp,ticker)
# #############################################################################################"

rm(URL,url,destFile,tickers_list,tagsToRead,tickerSymbols,names)
setwd(saveDir)
