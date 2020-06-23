# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.0
#
# --- rt analysis for DPX R40
# --- version: june 2020
#
# --- descriptive fr analysis

# ========================================================================
# -- Helper functions ----
getPacks <- function( packs ) {
  
  # Check wich packages are not intalled and install them
  if ( sum(!packs %in% installed.packages()[, 'Package'])) {
    install.packages( packs[ which(!packs %in% installed.packages()[, 'Package']) ], 
                      dependencies = T)
  }
  
  # Require all packages
  sapply(packs, require, character.only =  T)
  
}

# -- Load necessary packages
pkgs <- c('dplyr', 'plyr', 
          'emmeans', 'car', 'sjstats', 'ggplot2')
getPacks(pkgs)
rm(pkgs)



# Dataframe entsprechend FAs_sum_All erstellen: Baseline und Blocks zusammenpacken
Correct_sum_ID$ID <- as.factor(Correct_sum_ID$ID)
Correct_sum_ID$group <- as.factor(Correct_sum_ID$group)
Correct_sum_ID$reward <- as.factor(Correct_sum_ID$reward)
Correct_sum_ID$trialtype <- as.factor(Correct_sum_ID$trialtype)

# 
# Hits_sum_All <- Hits_All %>% dplyr::group_by(ID, Trialtype, Rew, Phase) %>%
#   dplyr::summarise(m_RT = mean(RT),
#                    se_RT=sd(RT)/sqrt(sum(!is.na(RT))),
#                    n = sum(!is.na(RT)))

# Effektkodierung: Alle Trialtypen mit AY vergleichen
Correct_sum_ID$trialtype <- relevel(Correct_sum_ID$trialtype, ref = "BY")
Correct_sum_ID$trialtype <- relevel(Correct_sum_ID$trialtype, ref = "BX")
Correct_sum_ID$trialtype <- relevel(Correct_sum_ID$trialtype, ref = "AX")      #Trialtypen in levels ordnen, letztes als Referenz
levels(Correct_sum_ID$trialtype)
contrasts(Correct_sum_ID$trialtype) <- contr.sum(4); contrasts(Correct_sum_ID$trialtype)

# Modell direkt auf Daten ohne summary
require(lmerTest)

# Modell mit contrasts direkt drin
rt_mod_log <- lm(log(m_rt_hit) ~ trialtype*group*reward, data = Correct_sum_ID,
                 contrasts=list(trialtype = 'contr.sum',
                                reward = 'contr.sum',
                                group = 'contr.sum'))
rt_mod_no_log <- lm(m_rt_hit ~ trialtype*group*reward, data = Correct_sum_ID,
                 contrasts=list(trialtype = 'contr.sum',
                                reward = 'contr.sum',
                                group = 'contr.sum'))

performance::r2(rt_mod_log)
performance::r2(rt_mod_no_log)   # Modelfit in R² = Prozent erklärte Varianz -> ohne log besser
rt_a_mod <- anova(rt_mod_no_log); rt_a_mod

# genestetes Modell
mod_log <- lmer(log(m_rt_hit) ~ trialtype*group*reward + (1|ID), data = Correct_sum_ID,
                contrasts=list(trialtype = 'contr.sum',
                               reward = 'contr.sum',
                               group = 'contr.sum'))
mod_no_log <- lmer(m_rt_hit ~ trialtype*group*reward + (1|ID), data = Correct_sum_ID,
                   contrasts=list(trialtype = 'contr.sum',
                                  reward = 'contr.sum',
                                  group = 'contr.sum'))

performance::r2(mod_log)
performance::r2(mod_no_log)   # Modelfit in R² = Prozent erklärte Varianz -> ohne log besser
a_mod <- anova(mod_no_log); a_mod

# Modell mit und ohne Logarhytmierung, gucken, bei welchem der Modelfit (R²) besser ist
rt_mod_log <- lm(log(m_rt_hit) ~ trialtype*group*reward, data = Correct_sum_ID)
rt_mod_no_log <- lm(m_rt_hit ~ trialtype*group*reward, data = Correct_sum_ID)   # ausprobieren, ob Rechnung mit oder ohne log besser
hist(log(Correct_sum_ID$m_rt_hit))
hist(Correct_sum_ID$m_rt_hit)         # besser ohne log, weil näher an NV
performance::r2(rt_mod_log)
performance::r2(rt_mod_no_log)   # Modelfit in R² = Prozent erklärte Varianz -> ohne log besser
rt_a_mod <- anova(rt_mod_no_log); rt_a_mod # Modell für ANOVA, type=3 -> Effekte unabhängig voneinander geprüft
 
# geht nicht wegen 'car'
# eta_sq(rt_a_mod, partial=F)  # Effektgröße Eta-Quadrat (hat Konventionen)
# car::qqPlot(resid(rt_mod_no_log))

# Trialtypes über Phasen hinweg
emmeans::emmeans(RT_mod_no_log, pairwise ~ Trialtype | Rew , adjust = "fdr") # paarweise Vergleiche aller Stufen
emmeans::emmip(RT_mod_no_log, Rew ~ Trialtype, type = "response", CIs = T) + # Vorhersage erwarteter RT nach Modell
  theme_bw() + 
  labs(y = "Vorhergesagte Reaktionszeiten",
       x = "Trialtypen",
       title = "Modellvorhersage Reaktionszeiten Haupttestung") + 
  theme(strip.background = element_blank(), 
        strip.text= element_text(color= "black", size = 12),
        axis.text = element_text(color='black', size = 12),
        axis.title = element_text(color='black', size = 13),
        plot.title = element_text(hjust = .5),
        legend.text = element_text(size = 12),
        legend.title = element_blank()) + 
  geom_line(position = position_dodge(.1), size = 1) +
  geom_point(position = position_dodge(.1), size = 3)
  
# Phasen über Trialtypes hinweg
emmeans::emmeans(RT_mod_no_log, pairwise ~ Phase | Rew , adjust = "fdr") # paarweise Vergleiche aller Stufen
emmeans::emmip(RT_mod_no_log, Rew ~ Phase, type = "response", CIs = T) + # Vorhersage erwarteter RT nach Modell
  theme_bw() + 
  labs(y = "Vorhergesagte Reaktionszeiten",
       x = "Phasen",
       title = "Modellvorhersage Reaktionszeiten Haupttestung") + 
  theme(strip.background = element_blank(), 
        strip.text= element_text(color= "black", size = 12),
        axis.text = element_text(color='black', size = 12),
        axis.title = element_text(color='black', size = 13),
        plot.title = element_text(hjust = .5),
        legend.text = element_text(size = 12),
        legend.title = element_blank()) + 
  geom_line(position = position_dodge(.1), size = 1) +
  geom_point(position = position_dodge(.1), size = 3)

##### Saving Plots #####

###### Emmips ######
## T über P
# Open a pdf file
pdf("./Desktop/emmip_RT_Main_TP.pdf", width = 10 , height = 10) 
# 2. Create a plot
emmeans::emmip(RT_mod_no_log, Rew ~ Trialtype, type = "response", CIs = T) + # Vorhersage erwarteter RT nach Modell
  theme_bw() + 
  labs(y = "Vorhergesagte Reaktionszeiten",
       x = "Trialtypen",
       title = "Modellvorhersage Reaktionszeiten Haupttestung") + 
  theme(strip.background = element_blank(), 
        strip.text= element_text(color= "black", size = 12),
        axis.text = element_text(color='black', size = 12),
        axis.title = element_text(color='black', size = 13),
        plot.title = element_text(hjust = .5),
        legend.text = element_text(size = 12),
        legend.title = element_blank()) + 
  geom_line(position = position_dodge(.1), size = 1) +
  geom_point(position = position_dodge(.1), size = 3)
# Close the pdf file
dev.off()

## P über T
# Open a pdf file
pdf("./Desktop/emmip_RT_Main_PT.pdf", width = 10 , height = 10) 
# 2. Create a plot
emmeans::emmip(RT_mod_no_log, Rew ~ Phase, type = "response", CIs = T) + # Vorhersage erwarteter RT nach Modell
  theme_bw() + 
  labs(y = "Vorhergesagte Reaktionszeiten",
       x = "Phasen",
       title = "Modellvorhersage Reaktionszeiten Haupttestung") + 
  theme(strip.background = element_blank(), 
        strip.text= element_text(color= "black", size = 12),
        axis.text = element_text(color='black', size = 12),
        axis.title = element_text(color='black', size = 13),
        plot.title = element_text(hjust = .5),
        legend.text = element_text(size = 12),
        legend.title = element_blank()) + 
  geom_line(position = position_dodge(.1), size = 1) +
  geom_point(position = position_dodge(.1), size = 3)
# Close the pdf file
dev.off()

###### Histogramme ######

# Open a pdf file
pdf("./Desktop/hist_main_RT_nolog.pdf", width = 10 , height = 10) 
# 2. Create a plot
hist(Hits_sum_All$m_RT, main = "Datenverteilung Reaktionszeiten Haupttestung (Original)", xlab = "Reaktionszeiten")
# Close the pdf file
dev.off()

# Open a pdf file
pdf("./Desktop/hist_main_RT_log.pdf", width = 10 , height = 10) 
# 2. Create a plot
hist(log(Hits_sum_All$m_RT), main = "Datenverteilung Reaktionszeiten Haupttestung (Logarithmiert)", xlab = "log(Reaktionszeiten)")
# Close the pdf file
dev.off()


