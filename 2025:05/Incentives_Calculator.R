#Install essential packages, not required to re install everytime. 
install.packages("openxlsx")
install.packages("readxl")
install.packages("tidyverse")

#loading packages (Required everytime)
library(tidyverse)
library(openxlsx)
library(readxl)

#distributive value in total 总金额 -> 输入下面的数值
#或者读取，我想裹到exe里
Total = 386494.33

#Read List of 规培人员
List_GP <- read.xlsx("规培.xlsx")

#Read List of Coefficient
List_Coefficient <- read.xlsx("coefficient.xlsx")
head(List_Coefficient)
Sum_Coefficient <- sum(List_Coefficient$测算系数)

#Read List of Evaluation
List_Evaluation <- read_excel("Evaluation.XLS")

#Read List of Assigned_Group (Group member list) & Day Of Stay (ave)
List_Group_DOS <- read.xlsx("Group&DOS.xlsx")

#Read List of Adjustments
List_Adjustments <- read.xlsx("Adjustments.xlsx")

#Delete all the not-counted programs
List_Evaluation_Step1 <- List_Evaluation %>% filter(项目 != "中医工作量", 项目 != "平均住院日新农合.居民.职工医保", 项目 != "重点学科", 岗位 != "")
List_Evaluation_Tidy <- List_Evaluation_Step1 %>% select(科室,项目,值)

#Matching Group No.
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科一组李小美"] <- "3"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科二组费海涛"] <- "7"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科四组温燕"] <- "4"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科五组吴兴萍"] <- "1"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科六组郑宏"] <- "2"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科七组高强"] <- "5"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科八组郭祥君"] <- "8"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科九组郭琳"] <- "6"
List_Evaluation_Tidy$科室[List_Evaluation_Tidy$科室 == "呼吸与危重症医学科RICU李勤"] <- "9"

#Adjusting Ratio
List_Evaluation_Tidy$值[List_Evaluation_Tidy$项目 == "集采药品考核"] <- List_Evaluation_Tidy$值[List_Evaluation_Tidy$项目 == "集采药品考核"] * (1/3)


#Calculate Group Sum
Group1 = List_Evaluation_Tidy %>% filter(科室 == "1") 
Group1SUM = sum(Group1$值)
Group2 = List_Evaluation_Tidy %>% filter(科室 == "2") 
Group2SUM = sum(Group2$值)
Group3 = List_Evaluation_Tidy %>% filter(科室 == "3") 
Group3SUM = sum(Group3$值)
Group4 = List_Evaluation_Tidy %>% filter(科室 == "4") 
Group4SUM = sum(Group4$值)
Group5 = List_Evaluation_Tidy %>% filter(科室 == "5") 
Group5SUM = sum(Group5$值)
Group6 = List_Evaluation_Tidy %>% filter(科室 == "6") 
Group6SUM = sum(Group6$值)
Group7 = List_Evaluation_Tidy %>% filter(科室 == "7") 
Group7SUM = sum(Group7$值)
Group8 = List_Evaluation_Tidy %>% filter(科室 == "8") 
Group8SUM = sum(Group8$值)
Group9 = List_Evaluation_Tidy %>% filter(科室 == "9") 
Group9SUM = sum(Group9$值)
GroupEval = c(Group1SUM, Group2SUM , Group3SUM , Group4SUM , Group5SUM , Group6SUM , Group7SUM , Group8SUM , Group9SUM)

#加上住院日
Group9_DOS <- List_Evaluation$值[List_Evaluation$科室 == "呼吸与危重症医学科RICU李勤"& List_Evaluation$项目 == "平均住院日新农合.居民.职工医保"]
DOS = c((8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "1"]))* 1000, 
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "2"]))* 1000, 
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "3"]))* 1000, 
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "4"]))* 1000,
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "5"]))* 1000,
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "6"]))* 1000,
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "7"]))* 1000,
        (8.5 - mean(List_Group_DOS$平均住院天数[List_Group_DOS$医疗组 == "8"]))* 1000,
        Group9_DOS)
DOS_Clean <- DOS[!is.na(DOS)]
GroupEval = GroupEval + DOS_Clean
GroupEvalSUM <- sum(GroupEval)

#可分配的金额
Coeff_Total <- Total - GroupEvalSUM - length(row(List_GP)) * 500 - sum(List_Adjustments$value)

#计算小组到个人 (如果重复计算，前面的三行一定要跑，这是初始化)
j <- 1 
gc <- 1
List_Group_DOS <- List_Group_DOS %>% mutate(Adjusted_Incentive= 0)

for (i in 1:nrow(List_Group_DOS)){
  if (!is.na(List_Group_DOS$医疗组[i + 1])){
    if(List_Group_DOS$医疗组[i + 1] == as.character(j)){
      gc = gc + 1
      next
    }
    else{
      if (gc == 2){
        List_Group_DOS$Adjusted_Incentive[i-1] <- GroupEval[j] * 0.6
        List_Group_DOS$Adjusted_Incentive[i] <- GroupEval[j] * 0.4
      }
      if (gc == 3){
        List_Group_DOS$Adjusted_Incentive[i-2] <- GroupEval[j] * 0.5
        List_Group_DOS$Adjusted_Incentive[i-1] <- GroupEval[j] * 0.25
        List_Group_DOS$Adjusted_Incentive[i] <- GroupEval[j] * 0.25
      }
      #这里之后会有一个gc == 4的情况
      gc = 1
      j = j + 1
    }
  }
  else{
    if (gc == 2){
      List_Group_DOS$Adjusted_Incentive[i-1] <- GroupEval[j] * 0.6
      List_Group_DOS$Adjusted_Incentive[i] <- GroupEval[j] * 0.4
    }
    if (gc == 3){
      List_Group_DOS$Adjusted_Incentive[i-2] <- GroupEval[j] * 0.5
      List_Group_DOS$Adjusted_Incentive[i-1] <- GroupEval[j] * 0.25
      List_Group_DOS$Adjusted_Incentive[i] <- GroupEval[j] * 0.25
    }
    break
  }
  
}

#把奖金加在coefficient的表上
List_Coeff_Dis <- List_Coefficient %>% mutate(Coeff_Distritution = 测算系数 * Coeff_Total/Sum_Coefficient) %>% left_join(List_Group_DOS %>% select(姓名,Adjusted_Incentive), by = '姓名') %>% mutate(Adjusted_Incentive = replace_na(Adjusted_Incentive,0)) 
#把adjustment加上
List_Coeff_Adjust <- List_Coeff_Dis %>% left_join(List_Adjustments,by = '姓名') %>% mutate(value = replace_na(value, 0))
#最终表格
List_Final <- List_Coeff_Adjust %>% mutate(Final = Coeff_Distritution + Adjusted_Incentive + value)
#输出一下
write.xlsx(List_Final, file = "Final.xlsx",sheetName = "sheet1")
