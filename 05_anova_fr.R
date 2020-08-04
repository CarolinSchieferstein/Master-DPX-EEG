# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
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


# Variablen als Faktoren
Incorrect_sum_ID$ID <- as.factor(Incorrect_sum_ID$ID)
Incorrect_sum_ID$group <- as.factor(Incorrect_sum_ID$group)
Incorrect_sum_ID$reward <- as.factor(Incorrect_sum_ID$reward)
Incorrect_sum_ID$trialtype <- as.factor(Incorrect_sum_ID$trialtype)

# Effektkodierung: Alle Trialtypen mit AX vergleichen
levels(Incorrect_sum_ID$trialtype)
Incorrect_sum_ID$trialtype <- relevel(Incorrect_sum_ID$trialtype, ref = "BY")
Incorrect_sum_ID$trialtype <- relevel(Incorrect_sum_ID$trialtype, ref = "BX")
Incorrect_sum_ID$trialtype <- relevel(Incorrect_sum_ID$trialtype, ref = "AY")      #Trialtypen in levels ordnen, letztes als Referenz
levels(Incorrect_sum_ID$trialtype)
contrasts(Incorrect_sum_ID$trialtype) <- contr.sum(4); contrasts(Incorrect_sum_ID$trialtype)
hist(Incorrect_sum_ID$FR)

contrasts(Incorrect_sum_ID$reward) <- contr.sum(2); contrasts(Incorrect_sum_ID$reward)
contrasts(Incorrect_sum_ID$group) <- contr.sum(2); contrasts(Incorrect_sum_ID$group)

# Anova
options(contrasts = c("contr.sum", "contr.poly"))
inc_mod <- lmer(log(FR) ~ trialtype*reward*group + (1|ID), data=Incorrect_sum_ID)
summary(inc_mod)
anova(inc_mod)
car::Anova(inc_mod, test = "F")
car::qqPlot(resid((inc_mod)))

sjPlot::plot_model(inc_mod, "int")
