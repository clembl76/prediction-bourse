setwd("C:/Users/Jawad/Documents/GitHub/prediction-bourse/")
Sys.setenv(LANG = "en")
Sys.setlocale( "LC_TIME", "English" )

# agrège tous les téléchargements et dezippage de données

source("getData_zonebourse.R")
source("getData_abcbourse.R")
source("getData_boursorama.R")