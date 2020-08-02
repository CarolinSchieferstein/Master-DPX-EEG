# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
#
# --- rt analysis for DPX R40
# --- version: july 2020
#
# --- rt - run and pbi analysis

# ========================================================================
# ------------------- import relevant extensions -------------------------
# Load necessary packages
require(plyr)
require(dplyr)

##### run analysis #####
# ----- 1) Sort dataframe for short (1x AX) and long runs (3x AX) mit ax_run ---------------------
# run = 0 -> n = 241
Correct_run_short <- Correct %>% group_by(group, reward) %>%
  filter( ifelse(lag(trialrun) == 0 , (trialtype == "AY" & lag(trialtype) == "AX"), NA ) ) %>%
  mutate(ax_run = 0)

# run = 2 -> n = 48
Correct_run_long <- Correct %>% group_by(group, reward) %>%
  filter( ifelse(lag(trialrun) == 2 , (trialtype == "AY" & lag(trialtype) == "AX"), NA ) ) %>%
  mutate(ax_run = 2)


# ----- 2) Model short vs long run ---------------------

Correct_run <- rbind(Correct_run_long, Correct_run_short)

# Plot
require(ggplot2)

Correct_run$reward <- as.factor(Correct_run$reward)
Correct_run$group <- as.factor(Correct_run$group)
Correct_run$ax_run <- as.factor(Correct_run$ax_run)

# absichern, dass plyr VOR dplyr geladen wird, ansonsten detach(package:plyr) und n ochmal versuchen
Correct_run_sum <- Correct_run %>% group_by(group, reward, ax_run) %>% 
  summarise(m_rt = mean(rt),
            sd_rt = sd(rt),
            se_rt = sd(rt)/sqrt(sum(!is.na(rt))),
            n = sum(!is.na(rt)))

run_plot <- ggplot(Correct_run_sum, aes(x = ax_run, y = m_rt, colour = ax_run)) +
  geom_errorbar(aes(ymin = m_rt-se_rt, ymax = m_rt+se_rt), width=.1, position=position_dodge(.5)) +
  geom_line(position = position_dodge(.5), color = "black") +
  geom_point(position = position_dodge(.5), size=3) + 
  scale_x_discrete() +
  theme_light() +
  facet_grid(group ~ reward, labeller = label_both)

print(run_plot)

# ----- 3) Model effect on AX by run ---------------------
# filter AX
run_on_ax <- filter(Correct, trialtype == "AX")

# Plot
require(ggplot2)

run_on_ax_sum <- run_on_ax %>% group_by(group, reward, trialrun) %>% 
  summarise(m_rt = mean(rt),
            sd_rt = sd(rt),
            se_rt = sd(rt)/sqrt(sum(!is.na(rt))),
            n = sum(!is.na(rt)))

run_on_ax_sum$group <- factor(run_on_ax_sum$group, labels = c("verzögert", "direkt"))
run_on_ax_sum$reward <- factor(run_on_ax_sum$reward, labels = c("off", "on"))

ax_plot <- ggplot(run_on_ax_sum, aes(x = trialrun, y = m_rt, group = 1, color = trialrun)) +
  geom_errorbar(aes(ymin = m_rt - se_rt, ymax = m_rt + se_rt), width = .1, position = position_dodge(.5)) +
  geom_line(position = position_dodge(.5), color = "black") +
  geom_point(position = position_dodge(.5), size = 3) + 
  scale_x_continuous(breaks = c(0,1,2,3,4,5,6,7,8,9,10,11)) +
  theme_light() +
  facet_grid(group ~ reward, labeller = label_both())

print(ax_plot)


# ==========================================
# ----- 5) Compute PBI ---------------------
## PBI RT
pbi_rt <- Correct_sum_ID %>% group_by(ID, reward, group) %>%
  mutate(pbi_rt = ifelse(trialtype == 'AY', (m_rt_hit - lead(m_rt_hit)) / (m_rt_hit + lead(m_rt_hit)), NA )) %>%
  filter(!is.na(pbi_rt)) %>%
  select(ID, group, reward, pbi_rt)

## PBI FR <- problematisch, teilweise negative Werte obwohl Quotient eig nur zwischen [0;1]
pbi_fr <- Incorrect_sum_ID %>% group_by(ID, reward, group) %>%
  mutate(pbi_fr = ifelse(trialtype == 'AY', (FR - lead(FR)) / (FR + lead(FR)), NA )) %>%
  filter(!is.na(pbi_fr)) %>%
  select(ID, group, reward, pbi_fr)


# ----- 5) Model PBI by group/reward---------------------
require(ggplot2)

pbi_plot <- pbi_rt %>% group_by(group, reward) %>%
  summarise(m_pbi = mean(pbi_rt),
            sd_pbi = sd(pbi_rt),
            se_pbi = sd(pbi_rt)/sqrt(sum(!is.na(pbi_rt))),
            n = sum(!is.na(pbi_rt)))

pbi_plot$group <- as.factor(pbi_plot$group)


pbi_p <- ggplot(pbi_plot, aes(x = group, y = m_pbi, group = 1, colour = group)) +
  geom_errorbar(aes(ymin = m_pbi - se_pbi, ymax = m_pbi + se_pbi), width = .1, position = position_dodge(.5)) +
  geom_line(position=position_dodge(.5), color = "black") +
  geom_point(position=position_dodge(.5), size=3) + 
  theme_light() +
  facet_grid( ~ reward)

print(pbi_p)


pbi_fr_plot <- pbi_fr %>% group_by(group, reward) %>%
  summarise(m_pbi = mean(pbi_fr),
            sd_pbi = sd(pbi_fr),
            se_pbi = sd(pbi_fr)/sqrt(sum(!is.na(pbi_fr))),
            n = sum(!is.na(pbi_fr)))

pbi_fr_plot$group <- as.factor(pbi_fr_plot$group)

pbi_p_fr <- ggplot(pbi_fr_plot, aes(x = group, y = m_pbi, group = 1, colour = group)) +
  geom_errorbar(aes(ymin = m_pbi - se_pbi, ymax = m_pbi + se_pbi), width = .1, position = position_dodge(.5)) +
  geom_line(position=position_dodge(.5), color = "black") +
  geom_point(position=position_dodge(.5), size=3) + 
  theme_light() +
  facet_grid( ~ reward)

print(pbi_p_fr)
