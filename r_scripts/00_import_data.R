# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 3.6.3
#
# --- rt analysis for DPX R40
# --- version: april 2020
#
# --- import rt and fb data

# ========================================================================
# ------------------- import relevant extensions ------------------------- 

# -- Helper functions ----
pkgs <- c('dplyr', 'plyr', 
          'emmeans', 'car', 'sjstats', 'ggplot2')
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

# ----- 1) Read in the rt data ---------------------

# rt data
path <- c("/run/media/carolin/2672-DC99/dpx_r40/derivatives/rt/all")

paths <- dir(path = path, full.names = T, pattern = "-rt.tsv$")
names(paths) <- basename(paths)

# ----- 2) Create data frame containing all files and observations

# Read in files
rt <- plyr::ldply(paths, read.table, sep ="\t", dec = ".", header=T)
rm(paths)

# Select columns with data, not names
rt <- select(rt, .id, block, reward, trial, probe, run, reaction_probes, rt)

# Default names substitue with right names through vector of same length
names(rt) <- c( "ID", "block", "reward", "trialnr", "trialtype", "trialrun", "reactiontype", "rt")

# Get rid of suffix in ID column
rt$ID <- gsub(rt$ID, 
              pattern = "-rt.tsv", 
              replacement = "")
rt$ID <- gsub(rt$ID, 
              pattern = "sub-", 
              replacement = "")

# reactiontype into factor
rt$reactiontype <- as.factor(rt$reactiontype)
levels(rt$reactiontype)

# ----- 3) Save dataset for later use

write.table(rt, '/run/media/carolin/2672-DC99/dpx_r40/rt.txt', row.names = F, sep = '\t')

# ----- 4) Read in the fb data ---------------------

fragebogen <- read.csv("/run/media/carolin/2672-DC99/dpx_r40/data_fb/data_DPX-R40-EEG_2020-04-17_16-25.csv",
                       sep = ",", fileEncoding = "utf-16")

fb <- select(fragebogen, SD01, age:TIME_SUM)

# Benennung, Kontrollitems fehlen: 49,59,63,67,72
names(fb) <- c("sex", "age", "Abschluss", "Beruf", "ID",
               "01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
               "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
               "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
               "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
               "41", "42", "43", "44", "45", "46", "47", "48", "50",
               "51", "52", "53", "54", "55", "56", "57", "58", "60",
               "61", "62", "64", "65", "66", "68", "69", "70",
               "71", "73", "74", "75", "76", "77", "78", "79", "80",
               "81", "82", "83", "84",
               "Dauer1", "Dauer2", "Dauer3", "Dauer4", "Dauer5", "Dauergesamt")

# Gruppenzuordnung
VP_Zuordnung <- read.delim("VP_Zuordnung.txt", header = TRUE, sep = "\t")
fb <- merge(fb,VP_Zuordnung, by = "ID")

# VP_Zuordnung wie in rt
VP_Zuordnung2 <- read.delim("VP_Zuordnung2.txt", header = TRUE, sep = "\t")
fb <- merge(fb,VP_Zuordnung2, by = "ID")

# ordnen
fb <- select(fb, id, group, sex:Dauergesamt)

# id wieder zu ID
colnames(fb)[colnames(fb)=="id"] <- "ID"

# Save dataset for later use
write.table(fb, '/run/media/carolin/2672-DC99/dpx_r40/data_fb/fb.txt', row.names = F, sep = '\t')
