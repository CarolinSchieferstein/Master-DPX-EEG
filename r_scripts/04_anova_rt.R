# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
#
# --- rt analysis for DPX R40
# --- version: june 2020
#
# --- descriptive rt analysis

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


# Variablen als Faktoren
Correct_sum_ID$ID <- as.factor(Correct_sum_ID$ID)
Correct_sum_ID$group <- as.factor(Correct_sum_ID$group)
Correct_sum_ID$reward <- as.factor(Correct_sum_ID$reward)
Correct_sum_ID$trialtype <- as.factor(Correct_sum_ID$trialtype)


# Effektkodierung: Alle Trialtypen mit AX vergleichen
levels(Correct_sum_ID$trialtype)
Correct_sum_ID$trialtype <- relevel(Correct_sum_ID$trialtype, ref = "BY")
Correct_sum_ID$trialtype <- relevel(Correct_sum_ID$trialtype, ref = "BX")
Correct_sum_ID$trialtype <- relevel(Correct_sum_ID$trialtype, ref = "AY")      #Trialtypen in levels ordnen, letztes als Referenz
levels(Correct_sum_ID$trialtype)

contrasts(Correct_sum_ID$trialtype) <- contr.sum(4); contrasts(Correct_sum_ID$trialtype)
contrasts(Correct_sum_ID$reward) <- contr.sum(2); contrasts(Correct_sum_ID$reward)
contrasts(Correct_sum_ID$group) <- contr.sum(2); contrasts(Correct_sum_ID$group)
options(contrasts = c("contr.sum", "contr.poly"))

hist(Correct_sum_ID$m_rt_hit)


corr_mod <- lmer(m_rt_hit ~ trialtype*reward*group + (1|ID), data=Correct_sum_ID)
summary(corr_mod)
anova(corr_mod)
car::Anova(corr_mod, test = "F")   # Wald F test mit Kenward-Roger df
car::qqPlot(resid((corr_mod)))

sjPlot::plot_model(corr_mod, "int")
