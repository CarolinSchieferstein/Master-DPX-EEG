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

# -------- Read in und Aufteilung/Ordnen bei 04 für Fehlerraten schon gemacht -> schon im Environment drin --------
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


# COMPUTE DESCRIPTIVE STATISTICS----

# Hits rauslesen, group_by Trialtype , group aufteilen, + summarise
Correct_sum <- Correct %>% group_by(trialtype, group) %>% 
                           summarise(m_rt = mean(rt),
                                     sd_rt = sd(rt),
                                     se_rt = sd(rt)/sqrt(sum(!is.na(rt))),
                                     n = sum(!is.na(rt)))

require(ggplot2)
ggplot(Correct_sum, aes(x=trialtype, y=m_rt)) +
  geom_errorbar(aes(ymin=m_rt-se_rt, ymax=m_rt+se_rt), colour="black", width=.1, position=position_dodge(.5)) +
  geom_line(position=position_dodge(.5)) +
  geom_point(position=position_dodge(.5), size=3) +
  facet_wrap(~group)


# group aesthetic anpassen, da momentan nur 1 Beobachtung pro Gruppe
# require(ggplot2)
# ggplot(Correct_sum, aes(x=trialtype, y=m_rt)) +
#   geom_errorbar(aes(ymin=m_rt-se_rt, ymax=m_rt+se_rt),
#                 colour="black",
#                 width=.25,                                # Breite der Querstriche am Ende der Fehlerbalken
#                 position=position_dodge(.25),
#                 size = .6) +
#   geom_line(position=position_dodge(.25), size = 1) +
#   geom_point(position=position_dodge(.25), size = 3) +
#   facet_wrap(~ group, ncol = 2, scales = 'free_y') +      # free_y --> y-Achse an beide teile einzeln
#   coord_cartesian(ylim = c(200, 500)) +                   # Range der Y-Achse
#   theme_classic() +                                       # weißer Hintergrund etc., gibt viele einfach ausprobieren, welches man möchte
#   labs(x = 'Trialtype', y = 'Mittlere Reaktionszeit', title = "Mittlere Reaktionszeit") +
#   theme(strip.background = element_blank(),
#         strip.text= element_text(color= "black", size = 12),
#         axis.text = element_text(color='black', size = 12),
#         axis.title = element_text(color='black', size = 13),
#         plot.title = element_text(hjust = .5),
#         legend.text = element_text(size = 12),
#         legend.title = element_blank())
# 
# 
