###############################################################
#   R Program to Set Up ABCD Data for Measurement Invariance  #
#                                                             #
#   Source: Gottfredson et al, 2019                           #
#   https://nishagottfredson.web.unc.edu/amnlfa               #
#                                                             #                                             
#   Author: Nicole Kennelly                                   #
#                                                             #
#   Updated: 8/28/24                                          #
#                                                             #
#   Purpose: This program is a template to perform data       #
#           setup and prepare ABCD data to be run in MPLUS    #
#           both manually and automatically using the         #
#           aMNLFA and MPLUSAutomation packages.              #
#                                                             #
###############################################################


##### 1. Load packages #####

pacman::p_load(haven,dplyr)


###### 2. Setup Demographics/Crosswalk File ######

# load multi-year demographic file

abcd_p_demo <- read_sas("~abcd_p_demo.sas7bdat", 
                        NULL)
View(abcd_p_demo)


# subset data to include only demographics variables
demo<-select(abcd_p_demo,src_subject_id,eventname,demo_sex_v2,race_ethnicity,demo_prnt_gender_id_v2,demo_prnt_ethn_v2,demo_prnt_race_a_v2___10,demo_prnt_race_a_v2___11)

# keep baseline demographics
demo<-filter(demo,eventname=="baseline_year_1_arm_1")  #N=11868

# load internal crosswalk
crosswalk <- read_sas("S:/ABCD/SAS Data/Internal ID Crosswalk/master_id_cw.sas7bdat", NULL)

# Join internal crosswalk to demo file
demo_join<-left_join(demo,crosswalk,by="src_subject_id")

demo_join<-rename(demo_join, "ID"="id_rel5")

###### 3. Recode Demographic Variables and Interaction variables #####



#Recode Child's Sex <---- Only run if using Child's Demographics
demo_1<-filter(demo_join,race_ethnicity<=3)
demo_c<-demo_1
demo_c$CSEX<-NA
demo_c$CSEX[demo_c$demo_sex_v2== "1" |  demo_c$demo_sex_v2=="3"]<-(-1)
demo_c$CSEX[demo_c$demo_sex_v2== "2" |  demo_c$demo_sex_v2=="4"]<-1


#Create variables for child's Sex and Race/ethnicity 

demo_c$CRACETH1<-NA
demo_c$CRACETH1[(demo_c$race_ethnicity==1)]<-(2/3) #White
demo_c$CRACETH1[(demo_c$race_ethnicity==2)]<-(-1/3) #Black
demo_c$CRACETH1[(demo_c$race_ethnicity==3)]<-(-1/3) #Latinx
demo_c$CRACETH2<-NA
demo_c$CRACETH2[(demo_c$race_ethnicity==1)]<-(0) #White
demo_c$CRACETH2[(demo_c$race_ethnicity==2)]<-(-1/2) #Black
demo_c$CRACETH2[(demo_c$race_ethnicity==3)]<-(1/2) #Latinx
demo_c$CSXRE1<-NA
demo_c$CSXRE1[(demo_c$CSEX=="-1" & demo_c$race_ethnicity==1)]<-(-2/3)# White Male
demo_c$CSXRE1[(demo_c$CSEX=="1" & demo_c$race_ethnicity==1)]<-(2/3)#White Female
demo_c$CSXRE1[(demo_c$CSEX=="-1" & demo_c$race_ethnicity==2)]<-(1/3)#Black Male
demo_c$CSXRE1[(demo_c$CSEX=="1" & demo_c$race_ethnicity==2)]<-(-1/3)#Black Female
demo_c$CSXRE1[(demo_c$CSEX=="-1" & demo_c$race_ethnicity==3)]<-(1/3)#Latinx Male
demo_c$CSXRE1[(demo_c$CSEX=="1" & demo_c$race_ethnicity==3)]<-(-1/3)# Latinx Female
demo_c$CSXRE2<-NA
demo_c$CSXRE2[(demo_c$CSEX=="-1" & demo_c$race_ethnicity==1)]<-(0) #White Male
demo_c$CSXRE2[(demo_c$CSEX=="1" & demo_c$race_ethnicity==1)]<-(0) #White Female
demo_c$CSXRE2[(demo_c$CSEX=="-1" & demo_c$race_ethnicity==2)]<-(1/2)#Black Male
demo_c$CSXRE2[(demo_c$CSEX=="1" & demo_c$race_ethnicity==2)]<-(-1/2)#Black Female
demo_c$CSXRE2[(demo_c$CSEX=="-1" & demo_c$race_ethnicity==3)]<-(-1/2)#Latinx Male
demo_c$CSXRE2[(demo_c$CSEX=="1" & demo_c$race_ethnicity==3)]<-(1/2)#Latinx Female

## Save Final demo file
demo_final<-demo_c[c(1,11:16)]

##### 4. Create new R Datasets for Measurement Invariance ######

#####  Cannabis Expectancies at Followup 2 ######

meeq_f2 <- read_sas("~/su_y_can_exp_f2.sas7bdat")

#Subset 
meeq_f2<-meeq_f2[c(1,3:8)] #<---check that "src_subject_id" is column 1


#join with demographics

meeq_f2_join<-left_join(demo_final,meeq_f2,by="src_subject_id")

# rename indicator variables

meeq_f2_2<-rename(meeq_f2_join,
                  "MEEQY1"="meeq_section_q01",
                  "MEEQY2"="meeq_section_q02",
                  "MEEQY3"="meeq_section_q03",
                  "MEEQY4"="meeq_section_q04",
                  "MEEQY5"="meeq_section_q05",
                  "MEEQY6"="meeq_section_q06")

# subset and save analytic dataset 
meeq_f2_ana<-select(meeq_f2_2,-src_subject_id)

# subset individuals not missing all expectancies
meeq_f2_ana_2<-subset(meeq_f2_ana, (!is.na(meeq_f2_ana[,7])) & (!is.na(meeq_f2_ana[,8]))& (!is.na(meeq_f2_ana[,9]))& (!is.na(meeq_f2_ana[,10]))& (!is.na(meeq_f2_ana[,11]))& (!is.na(meeq_f2_ana[,12])))

save(meeq_f2_ana_2,file="~/meeq_f2_ana.RData")
