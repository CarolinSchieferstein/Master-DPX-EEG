# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
#
# --- fb analysis for DPX R40
# --- version: may 2020
#
# --- descriptives for fb

# ========================================================================

# Load necessary packages
require(plyr)
require(dplyr)
require(ggplot2)
require(ggmap)
require(viridis)

###### Get the data #####
fb <- read.table('/run/media/carolin/2672-DC99/dpx_r40/data_fb/fb.txt', header = T)

# COMPUTE SCALE-SCORES
fb <- mutate(fb, BI = X17 + X18 + X33 + X40 + X44 + X15 + X12 ,
                 ZAP = X05 + X13 + X25 + X39 + X54 + X71 + X84 ,
                 BR = X03 + X09 + X04 + X19 + X30 + X31 + X32 + X38 + X45 + X47 ,
                 Imp = X29 + X35 + X36 + X48 + X53 + X57 + X68 + X70 ,
                 BAS = BI + ZAP + BR + Imp,
                 FFFS = X10 + X24 + X52 + X60 + X61 + X64 + X69 + X77 + X78 + X81 ,
                 BIS = X01 + X02 + X07 + X08 + X11 + X21 + X23 + X28 + X37 + X41 + X42 +
                       X55 + X56 + X62 + X65 + X66 + X74 + X75 + X76 + X79 + X80 + X82 + X83 ,
                 Panik = X16 + X22 + X46 + X58 + X73 + X26 ,
                 DK = X50 + X06 + X14 + X20 + X51 + X27 + X34 + X43)

# ordnen
fb <- select(fb, ID:Beruf, BI:DK, X01:X84, Dauergesamt)

##### COMPUTE DESCRIPTIVE STATISTICS FOR QUESTIONNAIRE #####
fb_sum <- fb %>% dplyr::group_by(group) %>%dplyr::summarise(m_age = mean(age) ,
                                                            sd_age = sd(age) ,
                                                            m_sex = mean(sex) ,
                                                            sd_sex = sd(sex) ,
                                                            m_dauer = mean(Dauergesamt) ,
                                                            sd_dauer = sd(Dauergesamt) ,
                                                            m_BI = mean(BI) ,
                                                            sd_BI = sd(BI) ,
                                                            m_ZAP = mean(ZAP) ,
                                                            sd_ZAP = sd(ZAP) ,
                                                            m_BR = mean(BR) ,
                                                            sd_BR = sd(BR) ,
                                                            m_Imp = mean(Imp) ,
                                                            sd_Imp = sd(Imp) ,
                                                            m_BAS = mean(BAS) ,
                                                            sd_BAS = sd(BAS) ,
                                                            m_FFFS = mean(FFFS) ,
                                                            sd_FFFS = sd(FFFS) ,
                                                            m_BIS = mean(BIS) ,
                                                            sd_BIS = sd(BIS) ,
                                                            m_Panik = mean(Panik) ,
                                                            sd_Panik = sd(Panik) ,
                                                            m_DK = mean(DK) ,
                                                            sd_DK = sd(DK)
                                                            )

fb_scalesum <- fb %>% dplyr::group_by(group) %>%dplyr::summarise(m_BI = mean(BI) ,
                                                                 m_ZAP = mean(ZAP) ,
                                                                 m_BR = mean(BR) ,
                                                                 m_Imp = mean(Imp) ,
                                                                 m_BAS = mean(BAS) ,
                                                                 m_BIS = mean(BIS) ,
                                                                 m_FFFS = mean(FFFS) ,
                                                                 m_DK = mean(DK) ,
                                                                 m_Panik = mean(Panik)
                                                                 )
                                                                
                                                                 
fb_demosum <- fb %>% dplyr::group_by(group) %>%dplyr::summarise(m_age = mean(age) ,
                                                                sd_age = sd(age) ,
                                                                m_sex = mean(sex) ,
                                                                sd_sex = sd(sex) ,
                                                                m_dauer = mean(Dauergesamt) ,
                                                                sd_dauer = sd(Dauergesamt)
                                                                )


##### PLOT DESCRIPTIVE STATISTICS FOR QUESTIONNAIRE #####
fb_plot <- fb_scalesum %>% tidyr::pivot_longer(-group, names_to = "fb", values_to = "value")
fb_plot$fb <- gsub(fb_plot$fb, pattern = "m_", replacement = "")

fb_plot$group <- factor(fb_plot$group, labels = c("verzögert", "direkt"))

fb_plot$fb <- as.factor(fb_plot$fb)
levels(fb_plot$fb)
fb_plot$fb <- factor(fb_plot$fb,levels(fb_plot$fb)[c(5,1,6,3,8,7,4,9,2)])
levels(fb_plot$fb)

require(ggplot2)
ggplot(fb_plot, aes(x = fb, y = value, fill = fb)) +
  geom_line(position = position_dodge(.5)) +
  geom_bar(position = position_dodge(.5), size = 3, stat = "identity") +
  labs(y = "Skalenmittelwerte",
       x = "RST-PQ Skalen",
       title = "Mittelwerte der Skalen des RST-PQ") +
  theme(strip.background = element_blank(),
        strip.text= element_text(color= "black", size = 12),
        axis.text = element_text(color='black', size = 10),
        axis.title = element_text(color='black', size = 13),
        plot.title = element_text(hjust = .5),
        legend.text = element_text(size = 12),
        legend.title = element_blank()) +
  scale_y_continuous(breaks = seq(10,90,10)) +
  scale_fill_viridis(option = "D", discrete = TRUE) +
  facet_wrap(~group)

