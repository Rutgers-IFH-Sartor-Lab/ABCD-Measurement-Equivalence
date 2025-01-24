###############################################################
#   R Program to Set Up ABCD Data for Measurement Invariance  #
#                                                             #
#   Source: Gottfredson et al, 2019                           #
#   https://nishagottfredson.web.unc.edu/amnlfa               #
#                                                             #                                             
#   Author: Nicole Kennelly                                   #
#                                                             #
#   Updated: 3/7/23                                           #
#                                                             #
#   Purpose: This program is a template to perform data       #
#           setup and prepare ABCD data to be run in MPLUS    #
#           both manually and automatically using the         #
#           aMNLFA and MPLUSAutomation packages.              #
#                                                             #
###############################################################



##### 1.Install and load required packages (if necessary) #####

pacman::p_load(aMNLFA,MplusAutomation,dplyr)


##### 2.Load R dataset meeq F2  #####

load("~/meeq_f2_ana.rdata")

#replace NA's
meeq_f2_ana[is.na(meeq_f2_ana)] <- (-999)

##### 3: Define aMNLFA object(aMNLFA.object) #####
meeq_f2_pos<- aMNLFA::aMNLFA.object(dir = "~", 
                                    mrdata = meeq_f2_ana, 
                                    indicators = c("MEEQY2","MEEQY3","MEEQY4"),
                                    catindicators = c("MEEQY2","MEEQY3","MEEQY4"),
                                    meanimpact = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"),
                                    varimpact = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"), 
                                    measinvar = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"),
                                    factors = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"),
                                    ID = "ID",
                                    thresholds = FALSE)

meeq_f2_neg<- aMNLFA::aMNLFA.object(dir = "~", 
                                    mrdata = meeq_f2_ana, 
                                    indicators = c("MEEQY1","MEEQY5","MEEQY6"),
                                    catindicators = c("MEEQY1","MEEQY5","MEEQY6"),
                                    meanimpact = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"),
                                    varimpact = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"), 
                                    measinvar = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"),
                                    factors = c("CSEX","CRACETH1","CRACETH2","CSXRE1","CSXRE2"),
                                    ID = "ID",
                                    thresholds = FALSE)

##### 3. Plot items over time and/or as a function of predictors(aMNLFA.itemplots) #####


aMNLFA.itemplots(meeq_f2_pos)
aMNLFA.itemplots(meeq_f2_neg)

##### 4. Draw a calibration sample create Mplus input files for mean impact, variance impact, and item-by-item measurement non-invariance (aMNLFA.sample)#####

aMNLFA.sample(meeq_f2_pos)
aMNLFA.sample(meeq_f2_neg)

##### 5. Create Mplus input files for mean impact, variance impact, and item-by-item measurement non-invariance (aMNLFA.initial) #####

aMNLFA.initial(meeq_f2_pos)
aMNLFA.initial(meeq_f2_neg)

##### 6. Incorporate all 'marginally significant' terms into simultaneous 
# MPlus input file #####


aMNLFA::aMNLFA.simultaneous(meeq_f2_neg)
aMNLFA::aMNLFA.simultaneous(meeq_f2_pos)

##### 7. Trim terms from simultaneous model using 5% False Discovery
# Rate correction for non-invariance terms and generate factor scores #####


aMNLFA::aMNLFA.final(meeq_f2_neg)
aMNLFA::aMNLFA.final(meeq_f2_pos)

##### 8a. Trim 

prune.object<-aMNLFA.prune(meeq_f2_neg)
aMNLFA.DIFplot(prune.object,"loading",log=FALSE)
aMNLFA.DIFplot(prune.object,"intercept",log=FALSE)

prune.object<-aMNLFA.prune(meeq_f2_pos)
aMNLFA.DIFplot(prune.object,"loading",log=FALSE)
aMNLFA.DIFplot(prune.object,"intercept",log=FALSE)



##### 8b. Generate Scores
aMNLFA::aMNLFA.scores(meeq_f2_neg)
aMNLFA::aMNLFA.scores(meeq_f2_pos)
