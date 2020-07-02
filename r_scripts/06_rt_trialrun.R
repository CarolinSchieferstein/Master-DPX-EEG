# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.0
#
# --- rt analysis for DPX R40
# --- version: july 2020
#
# --- rt - run analysis

# ========================================================================
# ------------------- import relevant extensions -------------------------
# Load necessary packages
require(plyr)
require(dplyr)

###### group by trialrun ######
Correct_run <- Correct %>% group_by(trialtype, group, reward, trialrun)

# trialruns sortieren, rt der AY nach AX-run analysieren?
# wenn event = AX und event+1 = AY, dann beides reinnehmen mit trialrun, group, reward
Correct_run <- filter(Correct_run, lead(trialtype == "AY", n = 2, order_by = trialrun))

  


# Correct_run <- filter(Correct, trialtype == "AX" | trialtype == "AY")
# 
# Correct_run <- Correct_run %>% group_by(trialtype, group, reward, trialrun) %>%
#                                summarise(m_rt = mean(rt),
#                                          sd_rt = sd(rt),
#                                          se_rt = sd(rt)/sqrt(sum(!is.na(rt))),
#                                          n = sum(!is.na(rt)))
# ## Plot ##
# require(ggplot2)
# run_plot <- ggplot(Correct_run, aes(x=trialtype, y=m_rt, group = 1, color= trialtype)) +
#   geom_errorbar(aes(ymin=m_rt-se_rt, ymax=m_rt+se_rt), width=.1, position=position_dodge(.5)) +
#   geom_line(position=position_dodge(.5), color = "black") +
#   geom_point(position=position_dodge(.5), size=3) + 
#   theme_light() +
#   facet_grid(group ~ reward ~ trialrun, labeller = label_both)
# 
# print(run_plot)
