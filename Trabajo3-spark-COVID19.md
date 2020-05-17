# Universidad EAFIT
# Curso ST0263 Tópicos Especiales en Telemática, 2020-1
# Estudiante: Juan Diego Saldarriaga - jsalda23@eafit.edu.co
# Trabajo 3 - SPARK sobre COVID19
### Trabajo individual
# Realizar análisis exploratorio de datos sobre datasets de COVID-19:

## 1. Fuentes de datos
 ### Se realizó la descarga de los siguientes datasets:
  #### A nivel mundial:
   ##### https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases
   ![](Imagenes/Descargas%20mundiales.PNG)

  #### A nivel colombia:
   ##### https://data.humdata.org/dataset/positive-cases-of-covid-19-in-colombia
   ![](Imagenes/Descargas-Colombia.PNG)

   ##### https://www.ins.gov.co/Paginas/Inicio.aspx
   ![](Imagenes/Descargas-Colombia2.PNG)

## 2. Ingesta y almacenamiento de datos
  ### Construcción del datalake en AWS con S3 y carga de datos
  ![](Imagenes/S3-Buckets.PNG)
  ![](Imagenes/S3-Mundial.PNG)
  ![](Imagenes/S3-Colombia.PNG)

## 3. Procesamiento: Análisis exploratorio de datos con pyspark

### Casos recuperados a nivel Mundial
#### En la siguiente imagen se puede evidenciar la primera parte del análisis exploratorio de los casos recuperados a nivel Mundial. El analisis completo se encuentra adjunto en la carpeta "RecuperadosMundialmente"
![](Imagenes/Primera_Imagen_AnalysisRecuperados_Mundial.PNG)
