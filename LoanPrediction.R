#Set Working directory
setwd("~/DataAnalytics/Loan Prediction")
#Read train and test sets
train<-read.csv("train_u6lujuX_CVtuZ9i.csv")
test<-read.csv("test_Y3wMUE5_7gLdaTN.csv")
#Look at structure of datasets
str(train)
str(test)
#Divide data into categorical and continuous sets
train_cont<-subset(train,select=c(Loan_ID,ApplicantIncome,CoapplicantIncome,LoanAmount,Loan_Amount_Term))
train_cat<-subset(train,select=-c(Loan_ID,ApplicantIncome,CoapplicantIncome,LoanAmount,Loan_Amount_Term))
library("pastecs")
#get detailed summary after setting significant digits
options(scipen = 100)
options(digits = 2)
stat.desc(train_cont)
apply(train_cat,2,function(x){length(unique(x))})
table(train_cat$Gender)
as.matrix(prop.table(table(train_cat$Gender)))
table(train_cat$Married)
as.matrix(prop.table(table(train_cat$Married)))
table(train_cat$Dependents)
as.matrix(prop.table(table(train_cat$Dependents)))
table(train_cat$Education)
as.matrix(prop.table(table(train_cat$Education)))
table(train_cat$Self_Employed)
as.matrix(prop.table(table(train_cat$Self_Employed)))
table(train_cat$Credit_History)
as.matrix(prop.table(table(train_cat$Credit_History)))
table(train_cat$Property_Area)
as.matrix(prop.table(table(train_cat$Property_Area)))
#Looking at dependency - SelfEmployed and Loan Status
library("gmodels")
CrossTable(train$Self_Employed,train$Loan_Status)
library("ggplot2")
ggplot(train,aes(Self_Employed,fill=Loan_Status))+geom_bar()+labs(title="Stacked chart",x="Employment Stat",y="Count")+theme_bw()
CrossTable(train$Gender,train$Loan_Status)
ggplot(train,aes(Gender,fill=Loan_Status))+geom_bar()+labs(title="Stacked chart",x="Employment Stat",y="Count")+theme_bw()
CrossTable(train$ApplicantIncome,train$Loan_Status)
ggplot(train,aes(Loan_Status,ApplicantIncome))+geom_boxplot()+labs(title="Box plot")
#Missing value treatment
table(is.na(train))
table(is.na(test))
colSums(is.na(train))
colSums(is.na(test))
summary(train$Loan_Amount_Term)
summary(train$LoanAmount)
summary(train$Credit_History)
#Let us impute the missing values with the mean/median values
train$LoanAmount[is.na(train$LoanAmount)] <- median(train$LoanAmount, na.rm = T)
train$Loan_Amount_Term[is.na(train$Loan_Amount_Term)] <- median(train$Loan_Amount_Term, na.rm = T)
train$Credit_History[is.na(train$Credit_History)] <- median(train$Credit_History, na.rm = T)
colSums(is.na(train))
test$LoanAmount[is.na(test$LoanAmount)] <- median(test$LoanAmount, na.rm = T)
test$Loan_Amount_Term[is.na(test$Loan_Amount_Term)] <- median(test$Loan_Amount_Term, na.rm = T)
test$Credit_History[is.na(test$Credit_History)] <- median(test$Credit_History, na.rm = T)
colSums(is.na(test))
#Outlier treatment for continuous variables
ggplot(train,aes(Loan_ID,ApplicantIncome))+geom_jitter()
ggplot(train,aes(Loan_ID,CoapplicantIncome))+geom_jitter()
train_new<-subset(train,(ApplicantIncome>30000))
str(train_new)
train_new1<-subset(train,(CoapplicantIncome>10000))
#tablestr(train_new1)
train<-subset(train,!(ApplicantIncome>30000))
train<-subset(train,!(CoapplicantIncome>10000))
str(train)
train<-subset(train,select=-c(Loan_ID))
#test<-subset(test,select=-c(Loan_ID))
#train_new1<-subset(train_new1,select=-c(Loan_ID))
#train_new<-subset(train_new,select=-c(Loan_ID))
#predict model
#library("rpart")
set.seed(123)
#model<-glm()
#tree<-rpart(Loan_Status~.,data=train,method="class",control = rpart.control(minsplit = 20,minbucket = 100,maxdepth = 10), xval = 5)
#tree<-rpart(Loan_Status~.,data=train,method="class")
#RandomForest
install.packages("randomForest")
library("randomForest")
forest<-randomForest(Loan_Status~.,data=train, nodesize=25,ntree=2000)
#train_merge<-cbind(train,train_new,train_new1)
#pred_train<-predict(tree,newdata = train,type="class")
library("lattice")
library("caret")
levels(test$Married) <- levels(train$Married)
#confusionMatrix(pred_train,train$Loan_Status)
#pred_test<-predict(tree,newdata = test,type="class")
predictionForest_test<-predict(forest,test)
solution<-data.frame(Loan_ID=test$Loan_ID,Loan_Status=predictionForest_test)
write.csv(solution,file="final_solution6.csv")

