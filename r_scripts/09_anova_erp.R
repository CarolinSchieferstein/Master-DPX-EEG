# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
#
# --- analysis for DPX R40
# --- version: july 2020
#
# --- anova for erp

# ========================================================================
# ------------------- import relevant extensions -------------------------
# Load necessary packages
require(plyr)
require(dplyr)
require(lmerTest)
require(lme4)
require(ggplot2)
require(emmeans)
require(car)
require(sjstats)

# ----- 1) Import csv ---------------------
path <- c("/run/media/carolin/2672-DC99/dpx_r40/derivatives/amp/all")

paths_170 <- dir(path = path, full.names = T, pattern = "-n170.tsv$")
names(paths_170) <- basename(paths_170)

paths_300 <- dir(path = path, full.names = T, pattern = "-p300.tsv$")
names(paths_300) <- basename(paths_300)

paths_cnv <- dir(path = path, full.names = T, pattern = "-cnv.tsv$")
names(paths_cnv) <- basename(paths_cnv)

# ----- 2) Create dataframes ---------------------
# Read in files
N170 <- plyr::ldply(paths_170, read.table, sep ="\t", dec = ".", header=T)
rm(paths_170)

P300 <- plyr::ldply(paths_300, read.table, sep ="\t", dec = ".", header=T)
rm(paths_300)

CNV <- plyr::ldply(paths_cnv, read.table, sep ="\t", dec = ".", header=T)
rm(paths_cnv)

# Select columns with data, not names
N170 <- select(N170, .id, condition, epoch, channel, value, time)
P300 <- select(P300, .id, condition, epoch, channel, value, time)
CNV <- select(CNV, .id, condition, epoch, channel, value, time)

# Default names substitue with right names through vector of same length
names(N170) <- c( "ID", "cue", "epoch", "channel", "value", "time")
names(P300) <- c( "ID", "cue", "epoch", "channel", "value", "time")
names(CNV) <- c( "ID", "cue", "epoch", "channel", "value", "time")

# Get rid of suffix in ID column
N170$ID <- gsub(N170$ID, 
              pattern = "-n170.tsv", 
              replacement = "")
N170$ID <- gsub(N170$ID, 
              pattern = "sub-", 
              replacement = "")
P300$ID <- gsub(P300$ID, 
                pattern = "-p300.tsv", 
                replacement = "")
P300$ID <- gsub(P300$ID, 
                pattern = "sub-", 
                replacement = "")
CNV$ID <- gsub(CNV$ID, 
                pattern = "-cnv.tsv", 
                replacement = "")
CNV$ID <- gsub(CNV$ID, 
                pattern = "sub-", 
                replacement = "")
N170$cue <- gsub(N170$cue, 
                pattern = "Correct ", 
                replacement = "")
P300$cue <- gsub(P300$cue, 
                pattern = "Correct ", 
                replacement = "")
CNV$cue <- gsub(CNV$cue, 
               pattern = "Correct ", 
               replacement = "")


# ----- 3) Save datasets for later use ---------------------

write.table(N170, '/run/media/carolin/2672-DC99/dpx_r40/N170.txt', row.names = F, sep = '\t')
write.table(P300, '/run/media/carolin/2672-DC99/dpx_r40/P300.txt', row.names = F, sep = '\t')
write.table(CNV, '/run/media/carolin/2672-DC99/dpx_r40/CNV.txt', row.names = F, sep = '\t')

# ----- 4) Prepare datasets for anova  ---------------------
# add group
VP_Zuordnung_erp <- read.delim("/run/media/carolin/2672-DC99/dpx_r40/VP_Zuordnung_erp.txt", header = TRUE, sep = "\t")
N170 <- read.table('/run/media/carolin/2672-DC99/dpx_r40/N170.txt', header = T)
P300 <- read.table('/run/media/carolin/2672-DC99/dpx_r40/P300.txt', header = T)
CNV <- read.table('/run/media/carolin/2672-DC99/dpx_r40/CNV.txt', header = T)

N170 <- merge(N170, VP_Zuordnung_erp, by = "ID")
P300 <- merge(P300, VP_Zuordnung_erp, by = "ID")
CNV <- merge(CNV, VP_Zuordnung_erp, by = "ID")

# summarise
N170_sum <- N170 %>% group_by(ID, group, cue, channel) %>% 
                     summarise(m_erp = mean(value),
                               sd_erp = sd(value),
                               se_erp = sd(value)/sqrt(sum(!is.na(value))),
                               n = sum(!is.na(value)))


P300_sum <- P300 %>% group_by(ID, group, cue, channel) %>% 
                     summarise(m_erp = mean(value),
                               sd_erp = sd(value),
                               se_erp = sd(value)/sqrt(sum(!is.na(value))),
                               n = sum(!is.na(value)))


CNV_sum <- CNV %>% group_by(ID, group, cue, channel) %>% 
                   summarise(m_erp = mean(value),
                             sd_erp = sd(value),
                             se_erp = sd(value)/sqrt(sum(!is.na(value))),
                             n = sum(!is.na(value)))


# ----- 5) ANOVA  ---------------------
# Variablen als Faktoren
N170_sum$ID <- as.factor(N170_sum$ID)
N170_sum$group <- as.factor(N170_sum$group)
N170_sum$cue <- as.factor(N170_sum$cue)
N170_sum$channel <- as.factor(N170_sum$channel)

P300_sum$ID <- as.factor(P300_sum$ID)
P300_sum$group <- as.factor(P300_sum$group)
P300_sum$cue <- as.factor(P300_sum$cue)
P300_sum$channel <- as.factor(P300_sum$channel)

CNV_sum$ID <- as.factor(CNV_sum$ID)
CNV_sum$group <- as.factor(CNV_sum$group)
CNV_sum$cue <- as.factor(CNV_sum$cue)
CNV_sum$channel <- as.factor(CNV_sum$channel)

# nur cue = A und cue = B vergleichen (corrects)
N170_sum_x <- filter(N170_sum, cue == c("A", "B"))      ?????????????????????????????????
P300_sum_x <- filter(P300_sum, cue == c("A", "B"))      ?????????????????????????????????
CNV_sum_x <- filter(CNV_sum, cue == c("A", "B"))        ?????????????????????????????????



# Effektkodierung cues
levels(N170_sum$cue)  # letztes Level dient als Referenkategorie
levels(P300_sum$cue)
levels(CNV_sum$cue)

contrasts(N170_sum$cue) <- contr.sum(2); contrasts(N170_sum$cue)
contrasts(N170_sum$channel) <- contr.sum(2); contrasts(N170_sum$channel)
contrasts(N170_sum$group) <- contr.sum(2); contrasts(N170_sum$group)
options(contrasts = c("contr.sum", "contr.poly"))

contrasts(P300_sum$cue) <- contr.sum(2); contrasts(P300_sum$cue)
contrasts(P300_sum$channel) <- contr.sum(2); contrasts(P300_sum$channel)
contrasts(P300_sum$group) <- contr.sum(2); contrasts(P300_sum$group)
options(contrasts = c("contr.sum", "contr.poly"))

contrasts(CNV_sum$cue) <- contr.sum(2); contrasts(CNV_sum$cue)
contrasts(CNV_sum$channel) <- contr.sum(2); contrasts(CNV_sum$channel)
contrasts(CNV_sum$group) <- contr.sum(2); contrasts(CNV_sum$group)
options(contrasts = c("contr.sum", "contr.poly"))

hist(N170_sum$m_erp)
hist(P300_sum$m_erp)
hist(CNV_sum$m_erp)


N170_mod <- lmer(m_erp ~ cue*channel*group + (1|ID), data=N170_sum)
summary(N170_mod)
anova(N170_mod)
car::Anova(N170_mod, test = "F")
car::qqPlot(resid((N170_mod)))

sjPlot::plot_model(corr_mod, "int")


P300_mod <- lmer(m_erp ~ cue*channel*group + (1|ID), data=P300_sum)
summary(P300_mod)
anova(P300_mod)
car::Anova(P300_mod, test = "F")
car::qqPlot(resid((P300_mod)))

sjPlot::plot_model(P300_mod, "int")


CNV_mod <- lmer(m_erp ~ cue*channel*group + (1|ID), data=CNV_sum)
summary(CNV_mod)
anova(CNV_mod)
car::Anova(CNV_mod, test = "F")
car::qqPlot(resid((CNV_mod)))

sjPlot::plot_model(CNV_mod, "int")







