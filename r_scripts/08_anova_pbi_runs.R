# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
#
# --- analysis for DPX R40
# --- version: july 2020
#
# --- anova for pbi and runs analysis

# ========================================================================
# ------------------- import relevant extensions ------------------------- 

# -- Helper functions ----
pkgs <- c('dplyr', 'plyr', 
          'emmeans', 'car', 'sjstats', 'ggplot2', 'lmerTest')
getPacks(pkgs)
rm(pkgs)

getPacks <- function( packs ) {
  
  # Check wich packages are not intalled and install them
  if ( sum(!packs %in% installed.packages()[, 'Package'])) {
    install.packages( packs[ which(!packs %in% installed.packages()[, 'Package']) ], 
                      dependencies = T)
  }
  
  # Require all packages
  sapply(packs, require, character.only =  T)
  
}


# Load nescessary packages
require(plyr)
require(dplyr)

# ----- 1) Runs on RT in AY ---------------------
# Dataframe wie Correct_run_sum aber + ID
run_rt <- rt %>% group_by(ID, group, reward) %>%
  mutate(lastrun = lag(trialrun), lasttrial = lag(trialtype)) %>%
  filter(trialtype == "AY" & lag(trialtype) == "AX" & reactiontype == "Correct")


run_rt$group <- as.factor(run_rt$group)
run_rt$reward <- as.factor(run_rt$reward)

rt_mod <- lmer(data = run_rt, rt ~ lastrun*group*reward + (1|ID))

car::Anova(rt_mod, test = "F")
sjPlot::plot_model(rt_mod, "diag")
sjPlot::plot_model(rt_mod, "pred")
sjPlot::plot_model(rt_mod, "int")

##########
run_sum_ID <- Correct_run %>% group_by(ID, group, reward, ax_run) %>% 
  summarise(m_rt = mean(rt),
            sd_rt = sd(rt),
            se_rt = sd(rt)/sqrt(sum(!is.na(rt))),
            n = sum(!is.na(rt)))

run_sum_ID$group <- as.factor(run_sum_ID$group)
run_sum_ID$reward <- as.factor(run_sum_ID$reward)
run_sum_ID$ax_run <- as.factor(run_sum_ID$ax_run)

# Effektkodierung von ax_run: 0 als Vergleichswert, letztes Level als Referenz
levels(run_sum_ID$ax_run)
run_sum_ID$ax_run <- relevel(run_sum_ID$ax_run, ref = "2")
levels(run_sum_ID$ax_run)

contrasts(run_sum_ID$ax_run) <- contr.sum(2); contrasts(run_sum_ID$ax_run)
contrasts(run_sum_ID$reward) <- contr.sum(2); contrasts(run_sum_ID$reward)
contrasts(run_sum_ID$group) <- contr.sum(2); contrasts(run_sum_ID$group)
options(contrasts = c("contr.sum", "contr.poly"))

hist(run_sum_ID$m_rt)

# ANOVA-Modell
run_mod <- lmer(m_rt ~ ax_run*reward*group + (1|ID), data=run_sum_ID)
summary(run_mod)
anova(run_mod)
car::Anova(run_mod, test = "F")
car::qqPlot(resid((run_mod)))

sjPlot::plot_model(run_mod, "int")


# ----- 2) Runs on FR/Hit-probability in AY ---------------------
# Runs on AY, probability for hit
AY_run <- rt %>% group_by(ID, group, reward) %>%
  mutate(lastrun = lag(trialrun), lasttrial = lag(trialtype), hit = ifelse(reactiontype == "Incorrect", 0, 1)) %>%
  filter(trialtype == "AY") %>%
  filter(!lasttrial %in% c("X", "Y"))

require(lme4)
require(lmerTest)

AY_run$lasttrial <- as.factor(AY_run$lasttrial)
AY_run$group <- as.factor(AY_run$group)
AY_run$reward <- as.factor(AY_run$reward)

prob_mod <- glmer(data = AY_run, hit ~ lastrun*lasttrial+group*reward + (1|ID), family = binomial(link = "logit"))
car::Anova(prob_mod)

sjPlot::plot_model(prob_mod, "int")
sjPlot::plot_model(prob_mod, "pred")
sjPlot::plot_model(prob_mod, "diag")


# ----- 3) PBI on RT ---------------------
# Dataframe = pbi_rt
# contrasts, keine Effektkodierung, da pbi intervallskaliert
pbi_rt$group <- as.factor(pbi_rt$group)
pbi_rt$reward <- as.factor(pbi_rt$reward)

contrasts(pbi_rt$reward) <- contr.sum(2); contrasts(pbi_rt$reward)
contrasts(pbi_rt$group) <- contr.sum(2); contrasts(pbi_rt$group)
options(contrasts = c("contr.sum", "contr.poly"))

hist(pbi_on_rt$m_rt)

# ANOVA-Modell
pbi_rt_mod <- lmer(pbi_rt ~ reward+group + (1|ID), data=pbi_rt) # random part (1|ID) überfittet -> singular fit d.h. Zellen sind zu ähnlich 
pbi_rt_mod <- lm(pbi_rt~ reward*group, data = pbi_rt)
summary(pbi_rt_mod)
anova(pbi_rt_mod)
car::Anova(pbi_rt_mod, test = "F")
car::qqPlot(resid((pbi_rt_mod)))

sjPlot::plot_model(pbi_rt_mod, "pred")


# ----- 3) PBI on FR ---------------------
# Dataframe = pbi_fr
# contrasts, keine Effektkodierung, da pbi intervallskaliert
pbi_fr$group <- as.factor(pbi_fr$group)
pbi_fr$reward <- as.factor(pbi_fr$reward)

contrasts(pbi_fr$reward) <- contr.sum(2); contrasts(pbi_fr$reward)
contrasts(pbi_fr$group) <- contr.sum(2); contrasts(pbi_fr$group)
options(contrasts = c("contr.sum", "contr.poly"))

hist(pbi_fr$pbi_fr)

# ANOVA-Modell
pbi_fr_mod <- lmer(pbi_fr ~ reward*group + (1|ID), data=pbi_fr) # random part (1|ID) überfittet -> singular fit
                                                                # d.h. Zellen sind zu ähnlich, Werte zwischen Personen sollten
                                                                # unterschiedlicher sein als intraindividuell hier aber
                                                                # scheinbar nicht und daher keine Varianzaufklärung dadurch
pbi_fr_mod <- lm(pbi_fr~ reward*group, data = pbi_fr)
summary(pbi_fr_mod)
anova(pbi_fr_mod)
car::Anova(pbi_fr_mod, test = "F")
car::qqPlot(resid((pbi_fr_mod)))

sjPlot::plot_model(pbi_fr_mod, "int")

