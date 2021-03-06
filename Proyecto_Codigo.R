#Cargando librer�as necesarias
library(tidyverse)
library(reshape2)
library(ggrepel)
library(scales)
library(plotly)
library(papeR)
library(knitr)
library(kableExtra)
library(MASS)
library(pROC)

#Cargamos temas propios de ggplot2
source('C:/Users/luisa/OneDrive/Documentos/own_themes.R')

#Importamos los datos
datos <- read.csv("C:/Users/luisa/Downloads/proj02/p2/bank-marketing_csv.csv", 
                  encoding = "UTF-8-BOM")
#Nombres de las columnas
colnames(datos) <- c('age', 'job', 'marital', 'education', 'default', 'balance', 
                     'housing', 'loan', 'contact', 'day', 'month', 'duration',
                     'campaign','pdays', 'previous', 'poutcome', "Class")

#Removemos las columnas de mes y d�a
datos <- datos[,-c(10,11)]

#Separamos las variables num�ricas y categ�ricas 
nums <- unlist(lapply(datos, is.numeric))
num <- datos[,nums]
cat <- datos[,!nums]
#num_exp <- melt(num[,-7])

#Construcci�n del dataframe para la gr�fica de dona
class_df <- data.frame(count = c(length(which(num$Class == 1)), length(which(num$Class == 2))), 
                       category = c("1", "2"))
class_df$frac <- class_df$count/sum(class_df$count)
class_df <- class_df[order(class_df$frac), ]
class_df$ymax = cumsum(class_df$frac)
class_df$ymin = c(0, head(class_df$ymax, n=-1))
class_df$labelPosition <- (class_df$ymax + class_df$ymin) / 2
class_df$label <- paste0(class_df$category, "\n Value: ", comma(class_df$count))

#Gr�fica de dona
ggplot(class_df, aes(fill = category, ymax = ymax, ymin = ymin, xmax = 4, xmin = 3)) +
  geom_rect() + geom_text_repel( x=2, aes(y=labelPosition, label=label, color=category), size=6, seed = 1) + 
  scale_fill_luis() + scale_color_luis() + coord_polar(theta="y") + xlim(c(-1, 4)) + theme_void() +
  theme(legend.position = "none")

#Distribuci�n de las edades
ggplot(datos, aes(x = age)) + geom_histogram(bins = 30, fill = '#002C54') + 
  scale_y_continuous(label = comma) + theme_luis() + 
  scale_x_continuous(breaks = seq(0,100, by = 10)) + xlab('Edad') + ylab(NULL)

#Funci�n para volver mayuscula la primera letra de un string
capFirst <- function(s) {
  paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "")
}

#Distribuci�n laboral
dist_job <- as.data.frame(table(datos$job))
dist_job <- dist_job[order(-dist_job$Freq),,drop = T]
row.names(dist_job) <- NULL
colnames(dist_job) <- c('Trabajo', '# de Clientes')
dist_job[,1] <- capFirst(dist_job[,1])
dist_job[,2] <- comma(dist_job[,2])
knitr::kable(dist_job) %>%
  kable_styling() %>%
  scroll_box(width = "900px", height = "300px")

#Funci�n para ordenar los factores en orden descendente
reorder_size <- function(x) {
  factor(x, levels = names(sort(table(x), decreasing = TRUE)))
}

#Creaci�n de dataframe para separar los graficos por clase
dat <- datos
dat$Class <- as.factor(dat$Class)

#Gr�fico de educaci�n
ggplotly(
  ggplot(dat, aes(reorder_size(education), fill = education)) + geom_bar(aes(y = (..count..)/sum(..count..)),position = "dodge") + 
    labs(x = "Education", y = NULL) + scale_y_continuous(label = percent) + 
    geom_text(aes( label = scales::percent((..count..)/sum(..count..)),
                   y= (..count..)/sum(..count..) + 0.008 ), stat= "count", position =  position_dodge(0.9),
              vjust = 0, size = 3) + theme_luis() + 
    scale_fill_luis() + theme(legend.position = "none")
)

#Gr�fico de cr�dito hipotecario
ggplotly(
  ggplot(dat, aes(reorder_size(housing), fill = housing)) + geom_bar(aes(y = (..count..)/sum(..count..)),position = "dodge") + 
    labs(x = "Housing", y = NULL) + scale_y_continuous(label = percent) + 
    geom_text(aes( label = scales::percent((..count..)/sum(..count..)),
                   y= (..count..)/sum(..count..) + 0.01 ), stat= "count", position =  position_dodge(0.9),
              vjust = 0, size = 3) + theme_luis() + 
    scale_fill_luis('wes1') + theme(legend.position = "none")
)

#Gr�fico de otros tipos de cr�dito
ggplotly(
  ggplot(dat, aes(reorder_size(loan), fill = loan)) + geom_bar(aes(y = (..count..)/sum(..count..)),position = "dodge") + 
    labs(x = "Loan", y = NULL) + scale_y_continuous(label = percent) + 
    geom_text(aes( label = scales::percent((..count..)/sum(..count..)),
                   y= (..count..)/sum(..count..) + 0.01 ), stat= "count", position =  position_dodge(0.9),
              vjust = 0, size = 3) + theme_luis() + 
    scale_fill_luis('wes1') + theme(legend.position = "none")
)

#Gr�fico de medios de contacto
ggplotly(
  ggplot(dat, aes(reorder_size(contact), fill = contact)) + geom_bar(aes(y = (..count..)/sum(..count..)),position = "dodge") + 
    labs(x = "Contact", y = NULL) + scale_y_continuous(label = percent) + 
    geom_text(aes( label = scales::percent((..count..)/sum(..count..)),
                   y= (..count..)/sum(..count..) + 0.01 ), stat= "count", position =  position_dodge(0.9),
              vjust = 0, size = 3) + theme_luis() + 
    scale_fill_luis() + theme(legend.position = "none")
)

#Gr�fico de la duraci�n de las llamadas
ggplotly(
  ggplot(dat, aes(x = Class, y = duration, fill = Class)) + geom_boxplot() + 
    labs(y = 'Duration') + scale_y_continuous(label = comma) + theme_luis() + 
    scale_fill_luis('wes1')
)

#Gr�fico de los resultados de la campa�a anterior
ggplotly(
  ggplot(dat, aes(reorder_size(poutcome), fill = Class)) + geom_bar(aes(y = (..count..)/sum(..count..)),position = "dodge") + 
    labs(x = "Previous Outcome", y = NULL) + scale_y_continuous(label = percent) + 
    geom_text(aes( label = scales::percent((..count..)/sum(..count..)),
                   y= (..count..)/sum(..count..) + 0.01 ), stat= "count", position =  position_dodge(0.9),
              vjust = 0, size = 3) + theme_luis() + 
    scale_fill_luis('wes1')
)

#Preparaci�n de los datos para la regresi�n log�stica
datos$Class <- datos$Class-1
datos$job <- factor(datos$job)
datos <- within(datos, job <- relevel(job, ref = 'unemployed'))
datos$contact <- factor(datos$contact)
datos <- within(datos, contact <- relevel(contact, ref = 'unknown'))
datos$education <- factor(datos$education)
datos <- within(datos, education <- relevel(education, ref = 'unknown'))
datos$loan <- factor(datos$loan)
datos <- within(datos, loan <- relevel(loan, ref = 'yes'))
datos$poutcome <- factor(datos$poutcome)
datos <- within(datos, poutcome <- relevel(poutcome, ref = 'unknown'))

#Regresi�n log�stica
log <- glm(Class ~ job + education + housing + loan + contact + poutcome, family = 'binomial', data = datos)

#Tabla de los coeficientes negativos
a <- data.frame(Coef = coef(log))
a <- a[order(a$Coef), , drop = F]
a <- a %>% filter(Coef < 0)
a$Coef <- round(a$Coef, 2)
rownames(a) <- capFirst(rownames(a))
knitr::kable(a) %>%
  kable_styling() %>%
  scroll_box(width = "900px", height = "300px")

#Tabla de los coeficientes negativos
b <- data.frame(Coef = coef(log))
b <- b[order(-b$Coef), , drop = F]
b <- b %>% filter(Coef >= 0)
b$Coef <- round(b$Coef, 2)
rownames(b) <- capFirst(rownames(b))
knitr::kable(b) %>%
  kable_styling() %>%
  scroll_box(width = "900px", height = "300px")

#Curva AUC-ROC
probs <- predict(log, type = 'response')
datos$probs <- probs
curves <- pROC::roc(Class ~ probs, data = datos, plot = TRUE, print.auc = TRUE)

#Tabla de predichos vs valores reales
fit1 <- predict(log, newdata = datos, type = "response")
fit1 <- ifelse(fit1 > 0.25,1,0)
tabla <- table(pred = fit1, actual = datos$Class)
tabladf <- data.frame(NR = comma(c(38733, 1189)), PR = comma(c(3994, 1295)))
colnames(tabladf) <- c('Negativo Real', 'Positivo Real')
rownames(tabladf) <- c('Negativo Predicho', 'Positivo predicho')
knitr::kable(tabladf) %>%
  kable_styling()

#Tablas de probabilidad
#Primera
test1 <- data.frame(job = unique(datos$job), education = rep('primary',12), housing = rep('no',12), 
                    loan = rep('no',12), contact = rep('cellular',12), poutcome = rep('success',12))
prob1 <- predict(log, newdata = test1, type = 'response')
test1$prob <- percent(round(prob1,2))
df <- test1
knitr::kable(df) %>%
  kable_styling()

#Segunda
test1 <- data.frame(job = 'blue-collar', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test2 <- data.frame(job = 'management', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test3 <- data.frame(job = 'technician', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test4 <- data.frame(job = 'admin.', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test5 <- data.frame(job = 'services', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
prob1 <- predict(log, newdata = test1, type = 'response')
prob2 <- predict(log, newdata = test2, type = 'response')
prob3 <- predict(log, newdata = test3, type = 'response')
prob4 <- predict(log, newdata = test4, type = 'response')
prob5 <- predict(log, newdata = test5, type = 'response')
test1$prob <- percent(prob1)
test2$prob <- percent(prob2)
test3$prob <- percent(prob3)
test4$prob <- percent(prob4)
test5$prob <- percent(prob5)
df <- rbind(test1, test2, test3, test4, test5)
knitr::kable(df) %>%
  kable_styling()

#Tercera
test1 <- data.frame(job = 'blue-collar', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test2 <- data.frame(job = 'management', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test3 <- data.frame(job = 'technician', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test4 <- data.frame(job = 'admin.', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test5 <- data.frame(job = 'services', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
prob1 <- predict(log, newdata = test1, type = 'response')
prob2 <- predict(log, newdata = test2, type = 'response')
prob3 <- predict(log, newdata = test3, type = 'response')
prob4 <- predict(log, newdata = test4, type = 'response')
prob5 <- predict(log, newdata = test5, type = 'response')
test1$prob <- percent(prob1)
test2$prob <- percent(prob2)
test3$prob <- percent(prob3)
test4$prob <- percent(prob4)
test5$prob <- percent(prob5)
df <- rbind(test1, test2, test3, test4, test5)
knitr::kable(df) %>%
  kable_styling()

#Cuarta
test1 <- data.frame(job = 'student', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test2 <- data.frame(job = 'student', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test3 <- data.frame(job = 'retired', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test4 <- data.frame(job = 'retired', education = 'primary', housing = 'no',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
prob1 <- predict(log, newdata = test1, type = 'response')
prob2 <- predict(log, newdata = test2, type = 'response')
prob3 <- predict(log, newdata = test3, type = 'response')
prob4 <- predict(log, newdata = test4, type = 'response')
test1$prob <- percent(prob1)
test2$prob <- percent(prob2)
test3$prob <- percent(prob3)
test4$prob <- percent(prob4)
df <- rbind(test1, test2, test3, test4)
knitr::kable(df) %>%
  kable_styling()

#Quinta
test1 <- data.frame(job = 'student', education = 'tertiary', housing = 'yes',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test2 <- data.frame(job = 'student', education = 'tertiary', housing = 'no',
                    loan = 'yes', contact = 'cellular', poutcome = 'failure')
test3 <- data.frame(job = 'retired', education = 'tertiary', housing = 'yes',
                    loan = 'no', contact = 'cellular', poutcome = 'failure')
test4 <- data.frame(job = 'retired', education = 'tertiary', housing = 'no',
                    loan = 'yes', contact = 'cellular', poutcome = 'failure')
test5 <- data.frame(job = 'student', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'telephone', poutcome = 'failure')
test6 <- data.frame(job = 'retired', education = 'tertiary', housing = 'no',
                    loan = 'no', contact = 'telephone', poutcome = 'failure')
prob1 <- predict(log, newdata = test1, type = 'response')
prob2 <- predict(log, newdata = test2, type = 'response')
prob3 <- predict(log, newdata = test3, type = 'response')
prob4 <- predict(log, newdata = test4, type = 'response')
prob5 <- predict(log, newdata = test5, type = 'response')
prob6 <- predict(log, newdata = test6, type = 'response')
test1$prob <- percent(prob1)
test2$prob <- percent(prob2)
test3$prob <- percent(prob3)
test4$prob <- percent(prob4)
test5$prob <- percent(prob3)
test6$prob <- percent(prob4)
df <- rbind(test1, test2, test3, test4, test5, test6)
knitr::kable(df) %>%
  kable_styling()

#Codigo auxiliar usado como gu�a
#Para referencia, no correr

# caret::varImp(log)
# datos$response <- predict(log, type = "response")
# 
# probs <- datos[,c(2,4,7,8,9,14:16)]
# 
# students <- probs %>%
#   filter(job == 'student')
# 
# blue_collar <- probs %>%
#   filter(job == 'blue-collar')
# 
# blue1 <- blue_collar %>%
#   filter(poutcome == 'success')
# 
# blue2 <- blue_collar %>%
#   filter(poutcome == 'failure')
# dur1 <- datos$duration[datos$Class == 1]
# boxplot(dur1)
# 
# dur2 <- datos[,c(10, 14, 15)]
# dur2 <- dur2[order(dur2$duration),,drop = F]
# 
# 
# dur <- rename(count(dur2, duration, poutcome, Class), Freq = n)
# 
# ggplot(dur, aes(x = duration, y = Freq, color = poutcome)) +
#   geom_point() + facet_wrap(facets = ~ Class, scales = 'free')
# 
# aaa <- dur2 %>%
#   filter(poutcome %in% c('success', 'other'))
# 
# first <- aaa %>%
#   filter(duration <= 127)
# 
# exito1 <- sum(first$Class)/length(first$Class)
# 
# sec <- aaa %>%
#   filter(duration > 127 & duration <= 359)
# 
# sec1 <- sec %>% 
#   filter(poutcome == 'other')
# 
# exito2 <- sum(sec$Class)/length(sec$Class)
# exito2_other <- sum(sec1$Class)/length(sec1$Class)
# 
# third <- aaa %>%
#   filter(duration > 359)
# exito3 <- sum(third$Class)/length(third$Class)
# 
# sum((datos$job == 'student') & (datos$Class == 1))
# sum((datos$job == 'student') & (datos$Class == 0))
# sum((datos$job == 'student'))
# sum((datos$job == 'retired') & (datos$Class == 1))
# sum((datos$job == 'retired') & (datos$Class == 0))