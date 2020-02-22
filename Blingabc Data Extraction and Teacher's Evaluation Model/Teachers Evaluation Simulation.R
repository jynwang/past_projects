

library(dplyr)
library(readxl)

##设置一级权重
##case2
#W <- matrix(c(0.35,0.2,0.2,0.15,0.1),1,5)
##case0 case1
W <- matrix(c(0.1,0.3,0.35,0.15,0.1),1,5)

##计算二级实际权重
w1 <- matrix(c(0.1,0.18,0.18,0.18,0.18,0.18),6,1)*W[1]
w2 <- matrix(c(0.15,0.1,0.25,0.30,0.20),5,1)*W[2]
w3 <- matrix(c(0.3,0.15,0.30,0.05,0.20),5,1)*W[3]
w4 <- matrix(c(0.4,0.6),2,1)*W[4]
w5 <- matrix(c(0.15,0.35,0.10,0.40),4,1)*W[5]

w=rbind(w1,w2,w3,w4,w5)
ww=rbind(w1,w2,w3,w5)

###初始值
initial <- read_excel("C:/Users/Wang/Desktop/initial.xlsx", col_names = FALSE, skip = 1)

TICOpoint <- as.matrix(initial[,2:23])%*%w*8.5
ID <- as.matrix(initial[,c(1,24,25)])
TICOall <- cbind(ID,TICOpoint)

inpoint <- as.matrix(initial[,c(2:17,20:23)])%*%ww*8.5

premonth <- read_excel("C:/Users/Wang/Desktop/premonth.xlsx", col_names = FALSE, skip = 1)
preclass <- read_excel("C:/Users/Wang/Desktop/preclass.xlsx", col_names = FALSE, skip = 1)
avgclass <- read_excel("C:/Users/Wang/Desktop/avgclass.xlsx", col_names = FALSE, skip = 1)



monthrule=c(5,17,35,59,89)
classrule=c(239,719,1439,2399,3599)

monthpoint=c(0,20,40,60,80,100)
classpoint=c(0,20,40,60,80,100)
#avgclass = 21

upgrade <-function(initial,avgclass,preclass,premonth,onm){
  
  for(i in onm)
  {
    n = premonth + i
    totoalclass= avgclass*i+preclass
    
    x = case_when(
      totoalclass<=classrule[1]~classpoint[1],
      totoalclass<=classrule[2]~classpoint[2],
      totoalclass<=classrule[3]~classpoint[3],
      totoalclass<=classrule[4]~classpoint[4],
      totoalclass<=classrule[5]~classpoint[5],
      totoalclass>classrule[5]~classpoint[6]
    )
    
    y = case_when(
      n<=monthrule[1]~monthpoint[1],
      n<=monthrule[2]~monthpoint[2],
      n<=monthrule[3]~monthpoint[3],
      n<=monthrule[4]~monthpoint[4],
      n<=monthrule[5]~monthpoint[5],
      n>monthrule[5]~monthpoint[6],
    )
    
    p = initial + (y*0.4+x*0.6)*W[4]*8.5
    TICOall <- cbind(TICOall,p)
  }
  
  return(TICOall)
}

onmonth = c(1:60)

TICOsimu <- upgrade(inpoint,avgclass[,2],preclass[,2],premonth[,2],onmonth)

#classify <- read_excel("C:/Users/Wang/Desktop/classify.xlsx")
#classify  = as.matrix(classify )

classify=c(350,445,550,580,610, 640,670,700,730,765, 810)

classification <-function(Mtico){
  
  TICOrank = c(0)
  TICOrank = TICOrank[-1]
  
  n=ncol(Mtico)
  
  for(i in 1:n)
  {
    M=case_when(
      Mtico[,i] <classify[1]~"DD",
      Mtico[,i] <classify[2]~"D",
      Mtico[,i] <classify[3]~"C2",
      Mtico[,i] <classify[4]~"C1",
      Mtico[,i] <classify[5]~"B2",
      Mtico[,i] <classify[6]~"B1",
      Mtico[,i] <classify[7]~"A2",
      Mtico[,i] <classify[8]~"A1",
      Mtico[,i] <classify[9]~"S2",
      Mtico[,i] <classify[10]~"S1",
      Mtico[,i] <classify[11]~"SS2",
      Mtico[,i] >=classify[11]~"SS1")
    
    TICOrank=cbind(TICOrank,M)
  }
  
  return(TICOrank)
}

TICOri <- classification(TICOsimu[,4:64])

TICOrank <- cbind(ID,TICOri)


setwd('C:/Users/Wang/Desktop')
write.csv(TICOrank,'ticoranksimu.csv')
write.csv(TICOsimu,'ticopointsimu.csv')


