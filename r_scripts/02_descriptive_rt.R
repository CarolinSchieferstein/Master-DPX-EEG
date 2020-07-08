# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.0
#
# --- rt analysis for DPX R40
# --- version: may 2020
#
# --- descriptive rt analysis

# ========================================================================
# ------------------- import relevant extensions -------------------------
# Load necessary packages
require(plyr)
require(dplyr)

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


# PLOT DESCRIPTIVE STATISTICS----
# Hits rauslesen, group_by Trialtype , group aufteilen, + summarise
Correct_sum <- Correct %>% group_by(trialtype, group, reward) %>% 
                           summarise(m_rt = mean(rt),
                                     sd_rt = sd(rt),
                                     se_rt = sd(rt)/sqrt(sum(!is.na(rt))),
                                     n = sum(!is.na(rt)))

# Plot
require(ggplot2)

Correct_sum$group <- factor(Correct_sum$group, labels = c("verzögert", "direkt"))
Correct_sum$reward <- factor(Correct_sum$reward, labels = c("off", "on"))

Correct_plot <- ggplot(Correct_sum, aes(x=trialtype, y=m_rt, group = 1, color= trialtype)) +
  geom_errorbar(aes(ymin=m_rt-se_rt, ymax=m_rt+se_rt), width=.1, position=position_dodge(.5)) +
  geom_line(position=position_dodge(.5), color = "black") +
  geom_point(position=position_dodge(.5), size=3) + 
  theme_light() +
  facet_grid(group ~ reward, labeller = label_both)

print(Correct_plot)
