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
url<-"http://finance.yahoo.com/q/cp?s=%5EFCHI"
script <- getURL(url)
doc <- htmlParse(script)

# get column names
li <- getNodeSet(doc, "//th[@class='yfnc_tablehead1']") 
colsL<-length(li)
colNames<- as.list(rep(NA, colsL))
for(i in 1:colsL){colNames[i]<-xmlValue(li[[i]][[1]])}

# create table
rm(cac40_tickers)
cac40_tickers<-data.frame(matrix(ncol = colsL, nrow = 40))
names(cac40_tickers)<-colNames

cac40_tickers_list<-""

#get column values
li <- getNodeSet(doc, "//td[@class='yfnc_tabledata1']") 
for(i in 1:40){
  # code
  cac40_tickers[i,1]<-xmlValue(li[[1+5*(i-1)]][[1]][[1]][[1]])
  # nom
  cac40_tickers[i,2]<-xmlValue(li[[2+5*(i-1)]][[1]])
  # je ne récupère pas les autres valeurs
  cac40_tickers_list<-paste(cac40_tickers_list,cac40_tickers[i,1],sep=",")
}

rm(url,script,doc,li,colsL,colNames)

# #############################################################################################"

# voir la documentation pour construire les urls ici
# http://www.canbike.org/information-technology/yahoo-finance-url-download-to-a-csv-file.html

#http://download.finance.yahoo.com/d/quotes.csv?s=IBM&f=nl1r&e=.csv
#http://download.finance.yahoo.com/d/quotes.csv?s=IBM&f=sl1d1t1c1ohgv&e=.csv

# #############################################################################################"

# all tags are in the tag.csv file
# g  Day's Low
# n  Name
# o  Open
# p  Previous Close
# p1	Price Paid
# s  Symbol
# v  Volume
tags<-read.csv("tags.csv",sep=";",header=TRUE)

# concatener tous les tags
# aa2a5bb2b3b4b6cc1c3c4c6c8dd1d2ee1e7e8e9f0f6gg1g3g4g5g6hii5jj1j2j3j4j5j6kk1k2k3k4k5ll1l2l3mm2m3m4m5m6m7m8nn4opp1p2p5p6qrr1r2r5r6r7ss1s6s7t1t6t7t8vv1v7ww1w4xy
names<-c('Ask','Average Daily Volume','Ask Size','Bid','Ask (Real-time)','Bid (Real-time)','Book Value','Bid Size','Change & Percent Change','Change','Commission','Currency','Change (Real-time)','After Hours Change (Real-time)','Dividend/Share','Last Trade Date','Trade Date','Earnings/Share','Error Indication (returned for symbol changed / invalid)','EPS Estimate Current Year','EPS Estimate Next Year','EPS Estimate Next Quarter','Trade Links Additional','Float Shares','Day's Low','Holdings Gain Percent','Annualized Gain','Holdings Gain','Holdings Gain Percent (Real-time)','Holdings Gain (Real-time)','Day's High','More Info','Order Book (Real-time)','52-week Low','Market Capitalization','Shares Outstanding','Market Cap (Real-time)','EBITDA','Change From 52-week Low','Percent Change From 52-week Low','52-week High','Last Trade (Real-time) With Time','Change Percent (Real-time)','Last Trade Size','Change From 52-week High','Percent Change From 52-week High','Last Trade (With Time)','Last Trade (Price Only)','High Limit','Low Limit','Day's Range','Day's Range (Real-time)','50-day Moving Average','200-day Moving Average','Change From 200-day Moving Average','Percent Change From 200-day Moving Average','Change From 50-day Moving Average','Percent Change From 50-day Moving Average','Name','Notes','Open','Previous Close','Price Paid','Change in Percent','Price/Sales','Price/Book','Ex-Dividend Date','P/E Ratio','Dividend Pay Date','P/E Ratio (Real-time)','PEG Ratio','Price/EPS Estimate Current Year','Price/EPS Estimate Next Year','Symbol','Shares Owned','Revenue','Short Ratio','Last Trade Time','Trade Links','Ticker Trend','1 yr Target Price','Volume','Holdings Value','Holdings Value (Real-time)','52-week Range','Day's Value Change','Day's Value Change (Real-time)','Stock Exchange','Dividend Yield')

# #############################################################################################"

tickerSymbols<-cac40_tickers_list
tagsToRead<-"aa2a5bb2b3b4b6cc1c3c4c6c8dd1d2ee1e7e8e9f0f6gg1g3g4g5g6hii5jj1j2j3j4j5j6kk1k2k3k4k5ll1l2l3mm2m3m4m5m6m7m8nn4opp1p2p5p6qrr1r2r5r6r7ss1s6s7t1t6t7t8vv1v7ww1w4xy"

# #############################################################################################"


URL<-paste("http://download.finance.yahoo.com/d/quotes.csv?s=",tickerSymbols,"&f=",tagsToRead,"&e=.csv",sep="")
destFile<-"quotes.csv"
download.file(URL,destFile)

# #############################################################################################"
# read downloaded file

cotations<-read.csv(destFile,sep=",",header=FALSE)
names(cotations)<-make.names(names,unique = FALSE, allow_ = TRUE)

# reste à faire: passer dans les bons formats
# par ex tous les champs qui ont "Date" dans leur nom
#cotations$date<-as.Date(cotations$date, "%d/%m/%y")


rm(URL,url,destFile,i,j,cac40_tickers_list,tagsToRead,tickerSymbols,names)
setwd(saveDir)