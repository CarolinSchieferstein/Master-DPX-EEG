import os
import glob
import re
import mne
from mne import pick_types, Epochs, combine_evoked
from mne.viz import plot_compare_evokeds
from mne.io import read_raw_fif
import numpy as np
import pandas as pd

# ========================================================================
# --- global settings
# prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if os.path.isdir(root_path):
    print('Setting "root_path" to ', root_path)
else:
    raise NameError('Directory not found!')

# path to eeg files
data_path = os.path.join(root_path, 'derivatives/pruned')
# output path
output_path = os.path.join(root_path, 'derivatives/rt')

# create directory for save
if not os.path.isdir(os.path.join(output_path)):
    os.mkdir(os.path.join(output_path))

# files to be analysed

files = sorted(glob.glob(os.path.join(data_path, '*-raw.fif')))

# === LOOP THROUGH FILES AND EXTRACT EPOCHS =========================
for file in files:
    # --- 1) set up paths and file names -----------------------
    filepath, filename = os.path.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) Read in the data ----------------------------------

    raw = read_raw_fif(file, preload=True)

    # sampling freq
    sfreq = raw.info['sfreq']

    # --- 3) RECODE EVENTS -----------------------------------------
    #  Get events
    evs = mne.find_events(raw,
                          stim_channel='Status',
                          output='onset',
                          min_duration=0.002)
    # Copy of events
    new_evs = evs.copy()
    broken = []
    trial = 0
    rt = np.zeros((1248, 4))
    # Recode reactions
    for i in range(len(new_evs[:, 2])):
        if new_evs[i, 2] == 71:
            if trial <= 48:
                rt[trial - 1, 3] = 0
            elif trial <= 448:
                rt[trial - 1, 3] = 1
            elif trial <= 848:
                rt[trial - 1, 3] = 2
            elif trial <= 1248:
                rt[trial - 1, 3] = 3

            next_t = new_evs[range(i, i + 3)]

            if [k for k in list(next_t[:, 2]) if k in {101, 102, 201, 202}]:
                rt[trial, 0] = (next_t[2, 0] - next_t[1, 0]) / sfreq
                if next_t[1, 2] > 20:
                    rt[trial, 1] = 0  # incongruent
                else:
                    rt[trial, 1] = 1
                if next_t[2, 2] > 200:
                    rt[trial, 2] = 0  # false
                else:
                    rt[trial, 2] = 1
                valid = True
                trial += 1
                continue
            else:
                broken.append(trial)
                rt[trial, 0] = np.nan
                if next_t[1, 2] > 20:
                    rt[trial, 1] = 0  # incongruent
                else:
                    rt[trial, 1] = 1
                # if next_t[2, 2] > 200:
                #     rt[trial, 2] = 0
                # else:
                #     rt[trial, 2] = 1
                rt[trial, 2] = np.nan
                valid = False
                trial += 1
                continue

        elif new_evs[:, 2][i] in {11, 12, 21, 22}:
            if new_evs[:, 2][i] in {11, 12}:
                suffix = 1  # Congr.
            elif new_evs[:, 2][i] in {21, 22}:
                suffix = 2  # Incongr.
            continue
        # Check if event preceded by other reaction

        elif new_evs[:, 2][i] in {101, 102, 201, 202} and valid:
            if trial <= 48:
                rt[trial - 1, 3] = 0
                if new_evs[:, 2][i] in [101, 102] and suffix == 1:
                    new_evs[:, 2][i] = 1091  # Correct Congr.
                elif new_evs[:, 2][i] in [101, 102] and suffix == 2:
                    new_evs[:, 2][i] = 1092  # Correct Incongr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 1:
                    new_evs[:, 2][i] = 1093  # Incorrect Congr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 2:
                    new_evs[:, 2][i] = 1094  # Incorrect Incongr.
                valid = False
                continue
            elif trial <= 448:
                rt[trial - 1, 3] = 1
                if new_evs[:, 2][i] in [101, 102] and suffix == 1:
                    new_evs[:, 2][i] = 2091  # Correct Congr.
                elif new_evs[:, 2][i] in [101, 102] and suffix == 2:
                    new_evs[:, 2][i] = 2092  # Correct Incongr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 1:
                    new_evs[:, 2][i] = 2093  # Incorrect Congr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 2:
                    new_evs[:, 2][i] = 2094  # Incorrect Incongr.
                valid = False
                continue
            elif trial <= 848:
                rt[trial - 1, 3] = 2
                if new_evs[:, 2][i] in [101, 102] and suffix == 1:
                    new_evs[:, 2][i] = 3091  # Correct Congr.
                elif new_evs[:, 2][i] in [101, 102] and suffix == 2:
                    new_evs[:, 2][i] = 3092  # Correct Incongr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 1:
                    new_evs[:, 2][i] = 3093  # Incorrect Congr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 2:
                    new_evs[:, 2][i] = 3094  # Incorrect Incongr.
                valid = False
                continue
            elif trial <= 1248:
                rt[trial - 1, 3] = 3
                if new_evs[:, 2][i] in [101, 102] and suffix == 1:
                    new_evs[:, 2][i] = 4091  # Correct Congr.
                elif new_evs[:, 2][i] in [101, 102] and suffix == 2:
                    new_evs[:, 2][i] = 4092  # Correct Incongr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 1:
                    new_evs[:, 2][i] = 4093  # Incorrect Congr.
                elif new_evs[:, 2][i] in [201, 202] and suffix == 2:
                    new_evs[:, 2][i] = 4094  # Incorrect Incongr.
                valid = False
                continue

        elif new_evs[:, 2][i] in {101, 102, 201, 202} and not valid:
            continue

    # arrays in rts to pd.dataframes and convert to txt
    frames = pd.DataFrame(rt)
    frames = frames.rename(index=int,
                           columns={0: 'rt',
                                    1: 'flanker',
                                    2: 'reaction',
                                    3: 'condition'})
    frames = frames.assign(subject=subj)
    frames.to_csv(os.path.join(output_path, 'sub-%s.tsv' % subj),
                  sep='\t',
                  index=True)





# rt = np.zeros((1200, 3))
# lc = [] #11
# li = [] #21
# rc = [] #12
# ri = [] #22

# for i in range(len(new_evs[152:])):
# if new_evs[152:][i, 2] == 71:
#   ind = np.count_nonzero(new_evs[0:i] == 71) - 1
## rt[ind][0] = (new_evs[i + 2, 0] - new_evs[i + 1, 0])
#  rt[ind][1] = new_evs[152:][i + 1, 2]
# rt[ind][2] = new_evs[152:][i + 2, 2]

# print(len(rt))

# rt_1 = np.zeros((3, 400))
# loop over participants
# for n in range(24):
# for i in range(3): # loop over blocks
# for t in range(400): # loop over trials
# rt[i][t] =
