#install.packages("XML") 
library(XML)

#Flux rss Zonebourse.com

# fonction de lecture d'un flux
getRSSitems <- function(type,print=TRUE) {
  
  RSSURL<-paste("http://www.zonebourse.com/rss/FeedAnalyses.php?type=",type,sep="")
  doc<-xmlTreeParse(RSSURL)   
  
  #xmlRoot(doc)
  src<-xpathApply(xmlRoot(doc), "//item") 
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
  
  # result <- list(center=center,spread=spread)
  return(DATA)
}

Actions <- getRSSitems("Actions") #Stratégie de Trading
Indices <- getRSSitems("Indices") #Stratégie Indices
