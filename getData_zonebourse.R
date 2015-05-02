#install.packages("XML") 
library(XML)
library(stringr)

#Flux rss Zonebourse.com

# fonction de lecture d'un flux
getRSSitems <- function(RSSURL,level,print=TRUE) {
  
  doc<-xmlTreeParse(RSSURL)   
  
  src<-xpathApply(xmlRoot(doc),paste( "//",level,sep=""))
  for (i in 1:length(src)) {
    if (i==1) {
      foo<-xmlSApply(src[[i]], xmlValue)
      DATA<-data.frame(t(foo), stringsAsFactors=FALSE)
    }
    else {
      foo<-xmlSApply(src[[i]], xmlValue)
      tmp<-data.frame(t(foo), stringsAsFactors=FALSE)
      DATA<-rbind(DATA, tmp)
    }
    
  }
  rm(doc)
  rm(src)
  return(DATA)
}

level<-"item"
Actions <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Actions",level) #Stratégie de Trading
Invests <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalysesFondamentales.php",level)#Stratégie d'investissement
Indices <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Indices",level) #Stratégie Indices
Forex <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Forex",level) #Stratégie Forex
Warrants <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Warrants",level) #Stratégie Warrants
Turbos <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Turbos",level) #Stratégie Turbos
Barons <- getRSSitems("http://www.zonebourse.com/rss/FeedBaronsBourse.php",level)# Barons de la bourse
Actualites <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php",level)# Toute l'actualité

getISIN<-function(table){
  
#a partir de guid récupérer nom et isin
  table$NameISIN<-t(data.frame(strsplit(as.character(table$guid),"/",fixed=TRUE))[4,])
  table$Name<-as.data.frame(str_match(table$NameISIN, "^(.*)-([0-9]*)$")[,-1])[,1]
  table$ISIN<-as.data.frame(str_match(table$NameISIN, "^(.*)-([0-9]*)$")[,-1])[,2]
  table<- subset(table, select=(-NameISIN)) 
return(table)
}

Invests$enclosure<-""
All<-rbind(Actions,Invests,Indices,Forex,Warrants,Turbos,Actualites)
All<-getISIN(All)
All<- subset(All, select=c(-enclosure,-guid)) 
