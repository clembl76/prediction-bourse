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

  getValuesList <- function(url,j,print=TRUE) {
    
    script <- getURL(url)
    doc <- htmlParse(script)
    
    for (i in 1:50) {
        
      #get NameISIN
      li <- getNodeSet(doc, paste("//td[@id='iAL",i,"']",sep=""))
      if (length(li)==0) break
      DATA[(j-1)*50+i,1]<-gsub("/","",xmlGetAttr(li[[1]][[1]],"href"))
      
      #get secteur
      li <- getNodeSet(doc, "//td[@class='large200 center']") 
      DATA[(j-1)*50+i,2]<-xmlGetAttr(li[[i]][[1]],"title")
      
      # get Var1janv and Capitalisation_MUSD
      li <- getNodeSet(doc, "//td[@class='large70 right pright20']")
      DATA[(j-1)*50+i,3]<-xmlValue(li[[i*2-1]][[1]][[1]])
      DATA[(j-1)*50+i,4]<-xmlValue(li[[i*2]][[1]])
      
      #get NoteInvestissement
      li <- getNodeSet(doc, "//td[@class='large110 center']")
      val<-xmlGetAttr(li[[i]][[1]],"title")
      DATA[(j-1)*50+i,5]<-if(is.null(val)){NA}else{val}  
      
      #get trends Court Moyen Long terme
      li <- getNodeSet(doc, "//td[@class='large20 center']")
      DATA[(j-1)*50+i,6]<-if(is.null(li[[i]][[1]][[1]])){NA}else{strsplit(strsplit(xmlGetAttr(li[[i]][[1]][[1]],"src"),'.',fixed=TRUE)[[1]][[1]],'_',fixed=TRUE)[[1]][[2]]}             

      #get page and row
      DATA[(j-1)*50+i,9]<-j
      DATA[(j-1)*50+i,10]<-i
    
    }
    rm(script);rm(doc);rm(li);rm(i);rm(j);rm(val)    
    return(DATA)   

  }
  
rm(DATA)
DATA<-data.frame(NameISIN=character(0),secteur=character(0),Var1janv=character(0),Capitalisation_MUSD=character(0),NoteInvestissement=character(0),CourtTerme=character(0),MoyenTerme=character(0),LongTerme=character(0),page=numeric(0),ligne=numeric(0))
DATA$NameISIN<-as.character(DATA$NameISIN);DATA$secteur<-as.character(DATA$secteur);
DATA$Var1janv<-as.character(DATA$Var1janv);DATA$Capitalisation_MUSD<-as.character(DATA$Capitalisation_MUSD);
DATA$NoteInvestissement<-as.character(DATA$NoteInvestissement);DATA$CourtTerme<-as.character(DATA$CourtTerme);
DATA$MoyenTerme<-as.character(DATA$MoyenTerme);DATA$LongTerme<-as.character(DATA$LongTerme);
DATA$page<-as.character(DATA$page);DATA$ligne<-as.character(DATA$ligne);

for (j in 1:20) {
  url<-paste("http://www.zonebourse.com/bourse/actions/Europe-3/France-51/?Req=&p=",j,sep="")
  DATA<-getValuesList(url,j)
}
