#Juan Diego Saldarriaga
#17/05/2020
#Topicos especiales en telematica.
#A continuacion se manipulan los datos de covid19 para su posterior graficacion.
#Version R -> 3.6.0

#Primero se cargan las librerias a emplear.
library(ggplot2)
library(dplyr)
library(tidyr)
library(grid)
library(gridExtra)

###########Preparacion de datos ############
#Cargamos los archivos de interes.
w_pos = read.csv("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/mundialtime_series_covid19_confirmed_global.csv")
w_death = read.csv("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/time_series_covid19_deaths_global.csv")
w_rec = read.csv("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/time_series_covid19_recovered_global.csv")
colombia = read.csv("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/Casos_positivos_de_COVID-19_en_Colombia.csv")

#Dado que R entiende registros como filas y variables como columnas y que no es posible realizar 
#analisis con las fechas como variables, deben manipularse las tablas para obtener los registros necesarios
w_pos2 = w_pos %>% gather(Date, Ammount, -Province.State, -Country.Region, -Lat, -Long)
w_death2 = w_death %>% gather(Date, Ammount, -Province.State, -Country.Region, -Lat, -Long)
w_rec2 = w_rec %>% gather(Date, Ammount, -Province.State, -Country.Region, -Lat, -Long)


#Verificamos estructura interna de las nuevas tablas y de los datos de colombia
str(w_pos2)
str(w_death2)
str(w_rec2)
str(colombia)

#Para graficar, vamos a necesitar las fechas como factores.
w_pos2$Date=as.factor(w_pos2$Date)
w_death2$Date=as.factor(w_death2$Date)
w_rec2$Date = as.factor(w_rec2$Date)

#Como hay varias provincias por pais, se deben organizar los datos por paises, arupando por pais y fecha
#y relizando las sumas.
w_pos2.2=w_pos2 %>%
  group_by(Country.Region, Date)%>%
  summarise(Ammount=sum(Ammount))%>%
  mutate(Ammount)

w_death2.2=w_death2 %>%
  group_by(Country.Region, Date)%>%
  summarise(Ammount=sum(Ammount))%>%
  mutate(Ammount)

w_rec2.2=w_rec2 %>%
  group_by(Country.Region, Date)%>%
  summarise(Ammount=sum(Ammount))%>%
  mutate(Ammount)
  

#Dada la cantidad de datos, se realizara una nueva tabla con solo algunos paises de interes
#Y se agregaran los totales mundiales.
#Paises seleccionados: Estados Unidos, Brasil, España, Italia y China 

#identifico nombres de paises
levels(w_pos2$Country.Region)

slx_pos=subset(w_pos2.2, w_pos2.2$Country.Region=="US" | w_pos2.2$Country.Region=="Brazil"|
                 w_pos2.2$Country.Region=="Spain" |w_pos2.2$Country.Region=="China"|
                 w_pos2.2$Country.Region=="Italy")

slx_death=subset(w_death2.2, w_death2.2$Country.Region=="US" | w_death2.2$Country.Region=="Brazil"|
                 w_death2.2$Country.Region=="Spain" |w_death2.2$Country.Region=="China"|
                 w_death2.2$Country.Region=="Italy")

slx_rec=subset(w_rec2.2, w_rec2.2$Country.Region=="US" | w_rec2.2$Country.Region=="Brazil"|
                   w_rec2.2$Country.Region=="Spain" |w_rec2.2$Country.Region=="China"|
                   w_rec2.2$Country.Region=="Italy")

#Vamos a realizar la suma de casos por fecha, para encontrar el total mundial.
tot_pos= w_pos2 %>%
  group_by(Date) %>%
  summarise(Ammount=sum(Ammount))%>%
  mutate(Ammount)

tot_pos$location="world" #Agregamos una columna indicando que se trata del mundo

tot_dead= w_death2 %>%
  group_by(Date) %>%
  summarise(Ammount=sum(Ammount))%>%
  mutate(Ammount)

tot_dead$location="world"#Agregamos una columna indicando que se trata del mundo

tot_rec= w_rec2 %>%
  group_by(Date) %>%
  summarise(Ammount=sum(Ammount))%>%
  mutate(Ammount)

tot_rec$location="world"#Agregamos una columna indicando que se trata del mundo


#Juntamos todos los datos, obtenemos una sola tabla para muertes y otra para positivos.
#Las tablas incluiran los paises de interes y el total calculado.
graph_pos=data.frame(Date=slx_pos$Date, Ammount=slx_pos$Ammount, location=slx_pos$Country.Region)
graph_pos=rbind(graph_pos, tot_pos)#Se juntan las tablas de positivos

graph_dead=data.frame(Date=slx_death$Date, Ammount=slx_death$Ammount, location=slx_death$Country.Region)
graph_dead=rbind(graph_dead, tot_dead)#Se juntan las tablas de muertes

graph_rec=data.frame(Date=slx_rec$Date, Ammount=slx_rec$Ammount, location=slx_rec$Country.Region)
graph_rec=rbind(graph_rec, tot_rec)#Se juntan las tablas de muertes

######Preparacion datos COLOMBIA.
#Para poder comparar los datos de Colombia con el mundo, es necesario extraer el número de casos
#por día en Colombia y, adicionlmente, para que sean comparables, es necesario
#agregar una escala de días y no fechas a ambas bases de datos (dia1 - dian)
#Dado que la base de datos de colombia está hecha por registro, si se quieresaber cuantos registros
#hay por fecha, solo basta con extraer la fecha y realizar una tabla de contingencia.
col=colombia$Fecha.de.notificaciÃ³n
col2=table(col)
col2=as.data.frame(col2)
col2$location="Colombia"
col2$Dia=c(1:length(col2[,1]))#Agregamos numero de dia

col2=col2 %>% 
  rename(Date = col,Ammount = Freq)#Cambiamos nombres de columnas para poder unir al mundo
#rbind requiere que las columnas tengan los mismos nombres y orden.

tot_pos$Dia=c(1:length(tot_pos$Date))#Agregamos numero de dia a positivos en el mundo.

pos_col_world=rbind(col2,tot_pos)
pos_col_world$Dia=as.factor(pos_col_world$Dia)#Volvemos los días factores, para poder graficar

###########Graficas################
#Para que el eje x sea visible, se deben quitar algunas fechas.
#Primero, se hallan los niveles de las fechas, para establecer inicio y final.
levels(graph_pos$Date)

#Positivos
positivos_mundo=ggplot(graph_pos, aes(x=Date, y = Ammount, color = location, group =location))+
  geom_point()+geom_line()+scale_x_discrete(breaks = c("X1.22.20", "X5.9.20"), 
                                              labels = c("22_Jan", "9_May"))+
  ggtitle("Número de caso positivos en algunos paises y el mundo")+
  theme_minimal()

positivos_mundo

ggsave("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/graficas/Positivos_mundo.png", positivos_mundo, units="in", width=8, height=5, dpi=300)

#Muertes
muertes_mundo=ggplot(graph_dead, aes(x=Date, y = Ammount, color = location, group =location))+
  geom_point()+geom_line()+scale_x_discrete(breaks = c("X1.22.20", "X5.9.20"), 
                                            labels = c("22_Jan", "9_May"))+
  ggtitle("Número de muertes en algunos paises y el mundo")+
  theme_minimal()

muertes_mundo

ggsave("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/graficas/Muertes_mundo.png", muertes_mundo, units="in", width=8, height=5, dpi=300)

#Recuperados
recuperados_mundo=ggplot(graph_rec, aes(x=Date, y = Ammount, color = location, group =location))+
  geom_point()+geom_line()+scale_x_discrete(breaks = c("X1.22.20", "X5.9.20"), 
                                            labels = c("22_Jan", "9_May"))+
  ggtitle("Número de caso recuperados en algunos paises y el mundo")+
  theme_minimal()

recuperados_mundo

ggsave("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/graficas/recuperados_mundo.png", recuperados_mundo, units="in", width=8, height=5, dpi=300)


#Colombia vs el mundo

Colombiavsmundo=ggplot(pos_col_world, aes(x=Dia, y = Ammount, color = location, group = location))+
  geom_point()+geom_line()+scale_x_discrete(breaks = c("1", "71", "115"), 
                                            labels = c("Dia_1", "Dia_71", "Dia_115"))+
  ggtitle("Número de casos Colombia vs mundo")+
  theme_minimal()

Colombiavsmundo

ggsave("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/graficas/Colombiavsmundo.png", Colombiavsmundo, units="in", width=8, height=5, dpi=300)

#Dado que la diferencia no es apreciable, debido a la diferencia explicada por la naturaleza exponencial
#de los registros en el mundo, se limita al día 71 para poder comparar.

Colombiavsmundo2=ggplot(pos_col_world, aes(x=Dia, y = Ammount, color = location, group = location))+
  geom_point()+geom_line()+scale_x_discrete(breaks = c("1", "71"), 
                                            labels = c("Dia_1", "Dia_71"),
                                            limits= as.factor(col2$Dia))+
  scale_y_continuous(limits = c(0,1e+06))+
  ggtitle("Número de casos Colombia vs mundo")+
  theme_minimal()

Colombiavsmundo2  

ggsave("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/graficas/Colombiavsmundo2.png", Colombiavsmundo2, units="in", width=8, height=5, dpi=300)

#Solo COlombia.
dias_col=levels(col2$Date)

Colombia=ggplot(col2, aes(x=Date, y = Ammount))+
  geom_point()+geom_line(group= "location")+scale_x_discrete(breaks = c(dias_col[1], dias_col[70]), 
                                            labels = c("mar/2", "may/14"))+
  ggtitle("Número de casos en Colombia") + theme_minimal()

Colombia

ggsave("C:/Users/JuanDiego/Desktop/Topicos_Telematica/Proyecto3/graficas/Colombia.png", Colombia, units="in", width=8, height=5, dpi=300)
