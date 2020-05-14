# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.0
#
# --- rt analysis for DPX R40
# --- version: may 2020
#
# --- descriptive fr analysis

# ========================================================================
# ------------------- import relevant extensions -------------------------
# Load necessary packages
require(plyr)
require(dplyr)

# ------------------- bis line 47 Wiederholung aus descriptive rt ---------
# Get the data
rt <- read.table('/run/media/carolin/2672-DC99/dpx_r40/rt.txt', header = T)

# VP_Zuordnung einlesen
VP_Zuordnung1 <- read.delim("/run/media/carolin/2672-DC99/dpx_r40/data_fb/VP_Zuordnung1.txt", header = TRUE, sep = "\t")
VP_Zuordnung2 <- read.delim("/run/media/carolin/2672-DC99/dpx_r40/data_fb/VP_Zuordnung2.txt", header = TRUE, sep = "\t")

VP_Zuordnung <- merge(VP_Zuordnung1, VP_Zuordnung2, by = "ID")
VP_Zuordnung <- select(VP_Zuordnung, id, group)
colnames(VP_Zuordnung)[colnames(VP_Zuordnung)=="id"] <- "ID"

# group Zuordnung in rt einfügen
rt <- merge(rt, VP_Zuordnung, by ="ID")

# Split dataset in reactiontypes
Correct <- filter(rt, reactiontype == 'Correct')
Incorrect <- filter(rt, reactiontype == 'Incorrect')
Missed <- filter(rt, reactiontype == 'Missed')
Too_soon <- filter(rt, reactiontype == 'Too_soon')

# Save datasets for later use
write.table(Correct, '/run/media/carolin/2672-DC99/dpx_r40/Correct.txt', row.names = F, sep = '\t')

write.table(Incorrect, '/run/media/carolin/2672-DC99/dpx_r40/Incorrect.txt', row.names = F, sep = '\t')

write.table(Missed, '/run/media/carolin/2672-DC99/dpx_r40/Missed.txt', row.names = F, sep = '\t')

write.table(Too_soon, '/run/media/carolin/2672-DC99/dpx_r40/Too_soon.txt', row.names = F, sep = '\t')


# ------------------- COMPUTE DESCRIPTIVE STATISTICS ---------------------

# Trialzahlen 
total_trials <- rt %>% dplyr::group_by(ID, trialtype, group) %>%
                       dplyr::summarise(total=sum(!is.na(trialnr)))

# Incorrects summary: mean und n
Incorrect_sum<- Incorrect %>% dplyr::group_by(ID, trialtype, group) %>%
                              dplyr::summarise(m_rt = mean(rt),
                                               n = sum(!is.na(rt))
                                               )

# Incorrect_sum mit Daten mit gezählten Trials zusammen
Incorrect_sum <- merge(Incorrect_sum, total_trials, c("ID", "trialtype", "group"))

# FEHLERRATE berechnen
Incorrect_sum <- mutate(Incorrect_sum, FR = n/total)

# Mittlere Fehlerrate und SE
Incorrect_sum_grouped <- Incorrect_sum %>% dplyr::group_by(trialtype) %>%
                                           dplyr::summarise(m_FR=mean(FR),
                                                            se_FR=sd(FR)/sqrt(sum(!is.na(FR)))
                                                            )
# FEHLERRATE Plotten
require(ggplot2)
ggplot(Incorrect_sum_grouped, aes(x=trialtype, y=m_FR)) + 
  geom_errorbar(aes(ymin=m_FR-se_FR, ymax=m_FR+se_FR), colour="black", width=.1, position=position_dodge(.5)) +
  geom_line(position=position_dodge(.5)) +
  geom_point(position=position_dodge(.5), size=3)