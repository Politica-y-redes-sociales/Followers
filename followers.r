library(readr)
library(dplyr)
library(rtweet)
library(curl)
library(sqldf)

token <- create_token(Consumer_Key<-"yvNgbzI4T0DXl1cBtxXEdZOSf",
                      Consumer_Secret<-"NE8yuGAnVJtB9uxM8aOjkFVUDUle1KlCQvmAaYQNCmuiKerYYa",
                      Access_Token<-"3089713545txuAs2ZwYOjkZPN9XGLU6iFItOREHJjNcfodS3x",
                      Access_Secret<-"5TXmHWG0YwcQaq2g78QD9DKWGszn728QXZAnEpqhxPaDF")

datos<- read.csv("/Users/alfonsoopazom/Downloads/Followers/Cuentas/Libro1.csv", header = TRUE, sep =";",encoding = "UTF-8")
carpeta<-paste("/Users/alfonsoopazom/Downloads/Followers","Resultados", sep="/")

if(file.exists(carpeta))
{}else
{dir.create(carpeta)}

i=1

for(i in 1:as.numeric(length(datos[,1]))) {
  Busqueda<-toString(datos$Cuenta[i])
  tweets1<- get_followers(Busqueda, n = 600000, retryonratelimit = TRUE)
  write.csv(tweets1, file=paste(carpeta,paste0("seguidores",Busqueda,".csv"),sep = "/"))
  Sys.sleep(15 * 60)
  for(i in 1:as.numeric(length(datos[,1])))
  {
    x <-sample(1:length(tweets1$user_id),90000,replace = TRUE)
    x <- as.data.frame(x)
    muestra<-sqldf("SELECT distinct(user_id) FROM tweets1")
    if(length(muestra[,1])>=90000)
    {
      muestra<-muestra[x[,1],]
      muestra<- as.data.frame(muestra)
      muestra <- sqldf("SELECT distinct(muestra) FROM muestra")
      write.csv(muestra, file=paste(carpeta,paste0("muestra-",Busqueda,".csv"),sep = "/"))
      
    }
  }
  tweets <- lookup_users(muestra$muestra)
  tweets<-as.data.frame(tweets)
  largo<-length(tweets[,1])
  
  if(largo>0)
  {  
    #Se parsean todo los datos de las columnas a Caracteres
    for(j in 1:length(tweets[1,]))
    {
      tweets[,j]<-as.character(tweets[,j])
    }
    
    total_seguidores<-sqldf("SELECT count(screen_name) 'Numero de seguidores' FROM tweets")
    cuentas_protegidas<-sqldf("SELECT screen_name Cuenta, protected Protegida FROM tweets WHERE protected!='FALSE'")
    n_protegidas<-sqldf("SELECT count(protected) 'Porcentaje'
                        FROM tweets WHERE protected!='FALSE'")
    porcentaje<-round((n_protegidas/total_seguidores)*100,2)
    cuentas<-datos$Cuenta[i]
    datos_finales <- cbind(porcentaje,cuentas)
  
    archivo_final <- paste(carpeta,paste0("porcentajes",Busqueda,".csv"),sep = "/")
    
    if(file.exists(archivo_final)){
      lista <- read.csv(archivo_final, header = TRUE)
      datos_finales <- rbind(datos_finales,lista)
      write.csv(datos_finales, file=archivo_final,row.names=FALSE)
    }else{
      write.csv(datos_finales, file=archivo_final,row.names=FALSE)
    }
    
  }
  print(datos$Cuenta[i])
  print(total_seguidores)
  print(n_protegidas)
  print(porcentaje)
}
