#install.packages("XML") 
library(XML)
library(stringr)


# ##############################################################################################################
#Flux rss Zonebourse.com
# ##############################################################################################################

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
Actions <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Actions",level) #Strat??gie de Trading
Invests <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalysesFondamentales.php",level)#Strat??gie d'investissement
Indices <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Indices",level) #Strat??gie Indices
Forex <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Forex",level) #Strat??gie Forex
Warrants <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Warrants",level) #Strat??gie Warrants
Turbos <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php?type=Turbos",level) #Strat??gie Turbos
Barons <- getRSSitems("http://www.zonebourse.com/rss/FeedBaronsBourse.php",level)# Barons de la bourse
Actualites <- getRSSitems("http://www.zonebourse.com/rss/FeedAnalyses.php",level)# Toute l'actualit??

getISIN<-function(table){
  
#a partir de guid r??cup??rer nom et isin
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


# ##############################################################################################################
# Aspirateur page Zonebourse.com
# ##############################################################################################################
library(RCurl)
library(XML)

url<-"http://www.zonebourse.com/GENFIT-16311755/fondamentaux/"
url<-"http://www.zonebourse.com/AXA-4615/fondamentaux/"
script <- getURL(url)
doc <- htmlParse(script)
li <- getNodeSet(doc, "//table[@class='ReutersTabInit']")

rm(script);rm(doc)#rm(url);

fillTable <- function(li,print=TRUE) {
  
  rows <- lapply(li, xpathSApply, "//tr[@class='ReutersTabOdd']", xmlValue)
  rows[sapply(rows, is.list)] <- NA
    
  t<-length(li) # nombre de tableaux
  l<-lapply(rows, length)[[1]][[1]] # nombre de lignes dans chaque tableau #pb n'est pas le meme dans chaque
  n<-t*l #total de lignes # du coup trop large
  
  DATA<-data.frame(section=character(0),title=character(0),subtitle=character(0),valY=character(0),valY1=character(0))
  DATA$section<-as.character(DATA$section)
  DATA$title<-as.character(DATA$title)
  DATA$subtitle<-as.character(DATA$subtitle)
  DATA$valY<-as.character(DATA$valY)
  DATA$valY1<-as.character(DATA$valY1)
  
  m=1
  for (i in 1:t) {
    for (j in 1:l) {   
      DATA[m,1]<-gsub('\\r\\n        ','',xmlValue(li[[i]][[1]][[1]][[1]])) #section_title
      DATA[m,2]<-gsub('\r\n        ','',xmlValue(li[[i]][[j+1]][[1]][[1]][[1]]))#title
      DATA[m,3]<-xmlValue(li[[i]][[j+1]][[1]][[3]][[1]]) #subtitle
      DATA[m,4]<-xmlValue(li[[i]][[j+1]][[2]][[2]][[1]]) # valY
      DATA[m,5]<-xmlValue(li[[i]][[j+1]][[3]][[2]][[1]]) # valY1      
      m<-m+1
    }
  }
  rm(i);rm(j);rm(n);rm(t);rm(l);rm(m);rm(k);rm(z)#rm(testRow);rm(z)
  
  #DATA<-subset(DATA,title!="NA" && valY!="NA") # a revoir, supprime 1 valeur de trop
  del<-c(3:8,15:16,23:24,29:32); DATA<-DATA[-del,]
  return(DATA)
}

rm(DATA)
DATA<-fillTable(li)
DATA$guid<-url
DATA<-getISIN(DATA)

# ##############################################################################################################
# R??cup??rer liste de toutes les valeurs France  Zonebourse.com
# ##############################################################################################################

url<-"http://www.zonebourse.com/bourse/actions/Europe-3/France-51/"

  getValuesList <- function(url,print=TRUE) {
    
    script <- getURL(url)
    doc <- htmlParse(script)
    DATA<-data.frame(NameISIN=character(0))
    DATA$NameISIN<-as.character(DATA$NameISIN)
    
    for (i in 1:50) {
      li <- getNodeSet(doc, paste("//td[@id='iAL",i,"']",sep=""))
      DATA[i,1]<-gsub("/","",xmlGetAttr(li[[1]][[1]],"href"))
    }
    rm(script);rm(doc);rm(li)    
    return(DATA)   

  }
  
rm(DATA)
DATA<-getValuesList(url)
