# rm(list = ls())
# install.packages('cowplot')

#*******************************************************************************************************
# summary function
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=F,
                        conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     median = median   (xx[[col]], na.rm=na.rm),
                     #do.call("rbind", tapply(xx[[col]], measurevar, quantile, c(0.25, 0.5, 0.75)))
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval:
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

#*******************************************************************************************************
# clean function 1
clean_data <- function (data) {
  sdata <- data
  
  sdata <- sdata[!is.na(sdata$Unsaturated_K2cm_cmhr), ]
  sdata <- sdata[!is.na(sdata$Percent_Sand), ]
  sdata <- sdata[!is.na(sdata$Type), ]
  
  sdata <- sdata[,c(which(colnames(sdata)=="Percent_Clay"),which(colnames(sdata)=="Percent_Silt")
                     , which(colnames(sdata)=="Percent_Sand"), which(colnames(sdata)=="Texture_mod")
                     , which(colnames(sdata)=="Soil_Series_Type"), which(colnames(sdata)=="Unsaturated_K2cm_cmhr")
  )]
  
  sdata <- sdata[!is.na(sdata$Texture_mod),]
  
  colnames(sdata) <- c("CLAY", "SILT", "SAND", "TEXTURE", "UF", "Unsaturated_K2cm_cmhr")
  
  # handle NA data
  sdata$sum <- sdata$CLAY + sdata$SILT + sdata$SAND
  
  # convert sum to 100
  sdata$ratio <- 100/sdata$sum
  
  sdata$CLAY <- sdata$CLAY*sdata$ratio
  sdata$SILT <- sdata$SILT*sdata$ratio
  sdata$SAND <- sdata$SAND*sdata$ratio
  
  sdata <- sdata[sdata$UF == "Urban Observed",]
  sdata <- sdata[!is.na(sdata$Unsaturated_K2cm_cmhr),]
  sdata <- sdata[!is.na(sdata$CLAY),]
  
  print(paste0('-----------------------obs(n)=',nrow(sdata)))
  
  sdata
}




#*******************************************************************************************************
# clean function 2
# length(sdata[which(sdata$Type == "fine granular structure"),]$Type)
update_structure <- function( data ) {
  
  sdata <- data
  
  sdata <- sdata[!is.na(sdata$Unsaturated_K2cm_cmhr), ]
  sdata <- sdata[!is.na(sdata$Percent_Sand), ]
  sdata <- sdata[!is.na(sdata$Type), ]
 
  sdata$Top_Type <- as.character(sdata$Top_Type)
  # sdata$Type <- as.character(sdata$Type)
  
  for ( i in 1:nrow(sdata) ) {
    
    if( sdata[i,]$Type == "fine granular structure" ) {
      sdata[i,]$Top_Type <- "granular" }
    else if ( sdata[i,]$Type == "single grain" ){
      sdata[i,]$Top_Type <- "single grain"
    }
    else if ( sdata[i,]$Type == "medium granular structure" ){
      sdata[i,]$Top_Type <- "granular"
    }
    else if (sdata[i,]$Type == "thin and medium plate-like structure"){
      sdata[i,]$Top_Type <- "platy"
    }
    else if (sdata[i,]$Type == "massive"){
      sdata[i,]$Top_Type <- "massive"
    }
    else if (sdata[i,]$Type == "medium subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"
    }
    else if (sdata[i,]$Type == "medium and fine granular"){
      sdata[i,]$Top_Type <- "granular"
    }
    else if (sdata[i,]$Type == "coarse granular blocky" ){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "fine subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"
    }
    
    else if (sdata[i,]$Type == "fine and medium granular structure" ){
      sdata[i,]$Top_Type <- "granular"
    }
    
    else if (sdata[i,]$Type == "medium platy structure" ){
      sdata[i,]$Top_Type <- "platy"}
    
    else if (sdata[i,]$Type == "fine and medium subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"
    }
    
    else if ( sdata[i,]$Type == "fine and medium prismatic structure" ){
      sdata[i,]$Top_Type <- "prismatic"}
    
    else if (sdata[i,]$Type == "medium granular and strong"){
      sdata[i,]$Top_Type <- "granular"
    }
    
    else if (sdata[i,]$Type == "medium angular blocky"){
      sdata[i,]$Top_Type <- "blocky"  }
    
    else if (sdata[i,]$Type == "fine angular structure"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "medium prismatic parting to moderate medium subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "medium prismatic structure parting to moderate medium subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "coarse prismatic"){
      sdata[i,]$Top_Type <- "prismatic"}
    
    else if (sdata[i,]$Type == "medium prismatic"){
      sdata[i,]$Top_Type <- "prismatic"}
    
    else if (sdata[i,]$Type == "angular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "very coarse prismatic structure"){
      sdata[i,]$Top_Type <- "prismatic"}
    
    else if (sdata[i,]$Type == "very fine granular structure"){
      sdata[i,]$Top_Type <- "granular"}
    
    else if (sdata[i,]$Type == "coarse subangular blocky"){ 
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "fine subangular and angular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "very fine and fine subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "medium and coarse subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "subangular blocky"){
      sdata[i,]$Top_Type <- "blocky"}
    
    else if (sdata[i,]$Type == "fine granular structure and weak very fine subangular blocky"){
      sdata[i,]$Top_Type <- "granular"  }
    
    else { sdata[i,]$Top_Type <- NA }
    
    print (paste0('******',i))
  }
  
  # 2 convert sum to 100
  sdata$sum <- sdata$Percent_Sand + sdata$Percent_Silt + sdata$Percent_Clay
  sdata$ratio <- 100/sdata$sum
  sdata$Percent_Clay <- sdata$Percent_Clay*sdata$ratio
  sdata$Percent_Silt <- sdata$Percent_Silt*sdata$ratio
  sdata$Percent_Sand <- sdata$Percent_Sand*sdata$ratio
  
  sdata$Top_Type <- as.factor(sdata$Top_Type)
  return (sdata)
}  



#*******************************************************************************************************
# prepare data for ANN and RF modeling

data_ann <- function (sdata) {
  ann_cols <- c("Percent_Sand", "Percent_Silt", "Percent_Clay", "Ksat_cmhr", "Unsaturated_K2cm_cmhr")
  sdata[, ann_cols]
}


data_rf <- function (sdata) {
  dataRF <- sdata[,c(which(colnames(sdata)=="Percent_Sand")
                     , which(colnames(sdata)=="Percent_Silt")
                     , which(colnames(sdata)=="Percent_Clay")
                     , which(colnames(sdata)=="Grade")
                     , which(colnames(sdata)=="Top_Type")
                     , which(colnames(sdata)=="Ksat_cmhr")
                     , which(colnames(sdata)=="Unsaturated_K2cm_cmhr")
                     , which(colnames(sdata)=="BulkDensity_gcm3")   )]
  return(dataRF)
}


#*******************************************************************************************************
# ANN model
ann_ssc <- function(sdata) {
  neuralnet(Unsaturated_K2cm_cmhr ~ Percent_Sand + Percent_Silt + Percent_Clay
            ,data=sdata, hidden=c(5,3), linear.output=T, stepmax=1e6)
} 

#*******************************************************************************************************
# RF1 model
rf_ssc <- function(sdata) {
  randomForest(Unsaturated_K2cm_cmhr ~ Percent_Sand + Percent_Silt + Percent_Clay , data=sdata,
               ntree = 100,
               mtry = 2,
               importance = TRUE,
               proximity = TRUE)
} 


#*******************************************************************************************************
# RF2 model
rf_sscs <- function(sdata) {
  randomForest(Unsaturated_K2cm_cmhr ~ Percent_Sand + Percent_Silt + Percent_Clay + Top_Type, data=sdata,
               ntree = 100,
               mtry = 2,
               importance = TRUE,
               proximity = TRUE)
} 

#*******************************************************************************************************
# plot and test RF2 

rf2_visual <- function (model) {
  p1 <- qplot(1:100,model$mse ) + geom_line() + theme_bw() +
    xlab ("Number of trees (n)") + ylab("MSE") +
    theme(axis.text.x = element_text(face = "bold", size = 12),
          axis.text.y = element_text(face = "bold", size = 12),
          axis.title = element_text(face = "bold", size = 12)
    ) 
  # annotate("text", x = 8, y = 7.15, label = "( a )", size = 6)
  
  # panel (b)
  p2 <- qplot(sort(importance(model, type = 1)[1:4]), 1:4) + geom_line() + theme_bw() +
    xlab ("Change of MSE (%)") +
    theme(axis.text.x = element_text(face = "bold", size = 12),
          axis.text.y = element_text(face = "bold", size = 12),
          axis.title = element_text(face = "bold", size = 12),
          axis.title.y = element_blank()
    ) + scale_y_continuous(labels = c("Structure", "%Silt", "%Clay", "%Sand") ) 
    # annotate("text", x =4.25, y = 3.75, label = "( b )", size = 6)
  
  # panel (c)
  p3 <- qplot(sort(importance(model, type = 2)[1:4]), 1:4) + geom_line() + theme_bw() +
    xlab ("Change of node purity") +
    theme(axis.text.x = element_text(face = "bold", size = 12),
          axis.text.y = element_text(face = "bold", size = 12),
          axis.title = element_text(face = "bold", size = 12),
          axis.title.y = element_blank()
    ) + scale_y_continuous(labels = c(" ", " ", " ", " ") ) 
    # annotate("text", x = 650, y = 3.75, label = "( c )", size = 6)
  
  panel_b <- plot_grid(p2, p3, ncol = 2)
  
  # print(panel_b)
  print(plot_grid(p1, panel_b, nrow = 2 ))
  invisible(list(p1,p2,p3, panel_b))
}


#*******************************************************************************************************
# model evaluation functions

model_evaluation1 <- function (sdata) {
  
  sdata$S_M <- sdata$kfs_m - sdata$kfs
  
  # hist(sdata$S_M)
  E <- round(sum(sdata$S_M)/length(sdata$S_M), 5)
  
  # t-test
  p <- round(t.test(sdata$S_M)$p.value, 5)
  
  # calculate d
  d <- round(1- sum(sdata$S_M^2)/sum((abs(sdata$kfs_m-mean(sdata$kfs))+abs(sdata$kfs-mean(sdata$kfs)))^2), 5)
  
  # calculate EF
  EF <- round(1- sum(sdata$S_M^2)/sum((sdata$kfs-mean(sdata$kfs))^2), 5)
  
  # calculate RMSE
  RMSE <- round((sum(sdata$S_M^2)/length(sdata$S_M))^0.5, 5)
  
  df <- t.test(sdata$S_M)[2]
  
  eval_mat <- data.frame(E, p, d, EF, RMSE, df)
  return(eval_mat)
}

#*******************************************************************************************************
# plot figure 4
# colnames(train)
# colnames(test_rosetta)
# max(data$Unsaturated_K2cm_cmhr)
model_evaluation2 <- function () {
  # a,b,c,d,e,f,g are data for panels a-h
  panel_a <- qplot(kfs_m, kfs, data = train) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50) +
    theme(axis.title.x = element_blank()) + theme(axis.title.y = element_blank())
  
  panel_b <- qplot(kfs_m, kfs, data = train_RF) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50)+
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  panel_c <- qplot(kfs_m, kfs, data = train_RF2) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50)+
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  panel_HSD <- qplot(kfs_m, kfs, data = train_RF2) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50)+
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  panel_d <- qplot(kfs_m, kfs, data = test) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50)+
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  panel_e <- qplot(kfs_m, kfs, data = test_RF) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50)+
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  panel_f <- qplot(kfs_m, kfs, data = test_RF2) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) + xlim(0, 50)+
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  panel_g <- qplot(kfs_m, kfs, data = test_rosetta) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 50) +
    theme(axis.title.x = element_blank())+ theme(axis.title.y = element_blank())
  
  y.grob <- textGrob(expression(Measured~K[fs]~cm~h^-1), 
                     gp=gpar(fontface="bold", col="black", fontsize=15), rot=90)
  
  x.grob <- textGrob(expression(Predicted~K[fs]~cm~h^-1), 
                     gp=gpar(fontface="bold", col="black", fontsize=15))
  
  plot <- plot_grid (panel_a, panel_d, panel_b, panel_e, panel_c, panel_f, panel_HSD, panel_g, ncol = 2, nrow = 4
                     , labels = c('( a ) ANN train', '( e ) ANN test', '( b ) RF1 train', '( f ) RF1 test'
                                  , '( c ) RF2 train', '( g ) RF2 test', '( d ) HSD     ', '( h ) ROSETTA')
                     , vjust = 3, hjust = c(-0.8, -0.8, -0.8, -0.8, -0.8, -0.8, -0.8, -0.75), label_size = 8)
  
  grid.arrange(arrangeGrob(plot, left = y.grob, bottom = x.grob))
}

#*******************************************************************************************************
# plot figure 5 

model_evaluation3 <- function () {
  
  panel_a <- qplot(Ksat_ANN, Ksat, data = histdata) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 25) + xlim(0, 25) +
    theme(axis.title.x = element_blank()) + theme(axis.title.y = element_blank())
  
  panel_b <- qplot(Ksat_RF, Ksat, data = histdata) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 25) + xlim(0, 25) +
    theme(axis.title.x = element_blank()) + theme(axis.title.y = element_blank())
  
  panel_c <- qplot(Ksat_RF2, Ksat, data = histdata) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 25) + xlim(0, 25) +
    theme(axis.title.x = element_blank()) + theme(axis.title.y = element_blank())
  
  panel_d <- qplot(Ksat_Rosseta, Ksat, data = histdata) + geom_abline(slope = 1, linetype = 2, size = 1.5, col = 'blue') +
    geom_smooth(method = 'lm', col = 'red') + ylim (0, 25) +
    theme(axis.title.x = element_blank()) + theme(axis.title.y = element_blank())
  
  y.grob <- textGrob(expression(Measured~K[fs]~cm~h^-1), 
                     gp=gpar(fontface="bold", col="black", fontsize=15), rot=90)
  
  x.grob <- textGrob(expression(Predicted~K[fs]~cm~h^-1), 
                     gp=gpar(fontface="bold", col="black", fontsize=15))
  
  plot <- plot_grid (panel_a, panel_c, panel_b, panel_d, ncol = 2, nrow = 2
                     , labels = c('( a ) ANN', '( c ) RF2', '( b ) RF1', '( d ) ROSETTA')
                     , vjust = 3, hjust = c(-1.2, -1.2, -1.2, -0.7), label_size = 8 )
  
  grid.arrange(arrangeGrob(plot, left = y.grob, bottom = x.grob))
  
}


