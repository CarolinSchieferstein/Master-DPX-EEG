# --- jose C. garcia alanis
# --- utf-8
# --- Python 3.7.3 / mne 0.18.1
#
# --- eeg pre-processing for dpx-r40
# --- version: june 2019
#
# --- import data, crate info for file
# --- save to .fif

# ========================================================================
# ------------------- import relevant extensions -------------------------
import os
import os.path as op
import glob
import re
import mne
import numpy as np
from mne import pick_types, Epochs, combine_evoked
from mne.viz import plot_compare_evokeds
from mne.io import read_raw_fif
from os import mkdir
import matplotlib as plt

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
output_path = os.path.join(root_path, 'derivatives/segmentation')
# path for saving epochs
epochs_path = os.path.join(root_path, 'derivatives/segmentation/epochs')

# create directory for save
if not os.path.isdir(os.path.join(output_path)):
    os.mkdir(os.path.join(output_path))

# files to be analysed
files = glob.glob(os.path.join(data_path, '*-raw.fif'))

if not op.isdir(op.join(data_path, 'epochs')):
    mkdir(op.join(data_path, 'epochs'))

erps = []
# === LOOP THROUGH FILES AND EXTRACT EPOCHS =========================
for file in files:

    # --- 1) set up paths and file names -----------------------
    filepath, filename = os.path.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) Read in the data ----------------------------------
    raw = read_raw_fif(file, preload=True)

    # --- 3) RECODE EVENTS -----------------------------------------
    #  Get events
    evs = mne.find_events(raw,
                          stim_channel='Status',
                          output='onset',
                          min_duration=0.002)

    # Copy of events
    new_evs = evs.copy()

    # Global variables
    broken = []
    trial = 0
    # Recode reactions
    for i in range(len(new_evs[:, 2])):
        if new_evs[:, 2][i] == 71:
            next_t = new_evs[range(i, i + 3)]
            if [k for k in list(next_t[:, 2]) if k in {101, 102, 201, 202}]:
                valid = True
                trial += 1
                continue
            else:
                broken.append(trial)
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

    # Copy of events
    # new_evs = evs.copy()

    # --- 4) PICK CHANNELS TO SAVE -----------------------------
    picks = pick_types(raw.info,
                       meg=False,
                       eeg=True,
                       eog=False,
                       stim=False)

    # --- 5) EXTRACT EPOCHS ------------------------------------

    if int(subj) in {1002, 1004, 1006, 1008,
                     1010, 1011, 1013, 1015,
                     1017, 1019, 1021, 1023,
                     1028}:
        # set event ids
        choice_event_id = {'P_Correct congr.': 1091,
                           'P_Correct incongr.': 1092,
                           'P_Incorrect congr.': 1093,
                           'P_Incorrect incongr.': 1094,
                           'S_Correct congr.': 2091,
                           'S_Correct incongr.': 2092,
                           'S_Incorrect congr.': 2093,
                           'S_Incorrect incongr.': 2094,
                           '+_Correct congr.': 3091,
                           '+_Correct incongr.': 3092,
                           '+_Incorrect congr.': 3093,
                           '+_Incorrect incongr.': 3094,
                           '-_Correct congr.': 4091,
                           '-_Correct incongr.': 4092,
                           '-_Incorrect congr.': 4093,
                           '-_Incorrect incongr.': 4094
                           }
    else:
        choice_event_id = {'P_Correct congr.': 1091,
                           'P_Correct incongr.': 1092,
                           'P_Incorrect congr.': 1093,
                           'P_Incorrect incongr.': 1094,
                           'S_Correct congr.': 2091,
                           'S_Correct incongr.': 2092,
                           'S_Incorrect congr.': 2093,
                           'S_Incorrect incongr.': 2094,
                           '-_Correct congr.': 3091,
                           '-_Correct incongr.': 3092,
                           '-_Incorrect congr.': 3093,
                           '-_Incorrect incongr.': 3094,
                           '+_Correct congr.': 4091,
                           '+_Correct incongr.': 4092,
                           '+_Incorrect congr.': 4093,
                           '+_Incorrect incongr.': 4094
                           }

    # Extract choice epochs
    choice_epochs = Epochs(raw, new_evs, choice_event_id,
                           on_missing='ignore',
                           tmin=-1,
                           tmax=1,
                           baseline=(-.550, -.300),
                           preload=True,
                           reject_by_annotation=True,
                           picks=picks)

    choice_epochs.save(op.join(epochs_path,
                               'sub-%s_cues-epo.fif' % subj),
                       overwrite=True)

    keys = {  # 'P_Correct congr.',
        # 'P_Correct incongr.',
        # 'P_Incorrect congr.',
        # 'P_Incorrect incongr.',
        # 'S_Correct congr.',
        'S_Correct incongr.',
        # 'S_Incorrect congr.',
        'S_Incorrect incongr.',
        # '+_Correct congr.',
        '+_Correct incongr.',
        # '+_Incorrect congr.',
        '+_Incorrect incongr.',
        # '-_Correct congr.',
        '-_Correct incongr.',
        # '-_Incorrect congr.',
        '-_Incorrect incongr.'}

    evokeds = {key: choice_epochs[key].average() for key in keys}

    erps.append(evokeds)

    neg_incorrect = [erps[i]['-_Incorrect incongr.'] for i in range(len(erps))]
    ga_neg_incorrect = mne.grand_average(neg_incorrect, drop_bads=False)
    neg_correct = [erps[i]['-_Correct incongr.'] for i in range(len(erps))]
    ga_neg_correct = mne.grand_average(neg_correct, drop_bads=False)

    pos_incorrect = [erps[i]['+_Incorrect incongr.'] for i in range(len(erps))]
    ga_pos_incorrect = mne.grand_average(pos_incorrect, drop_bads=False)
    pos_correct = [erps[i]['+_Correct incongr.'] for i in range(len(erps))]
    ga_pos_correct = mne.grand_average(pos_correct, drop_bads=False)

    sol_incorrect = [erps[i]['S_Incorrect incongr.'] for i in range(len(erps))]
    ga_sol_incorrect = mne.grand_average(sol_incorrect, drop_bads=False)
    sol_correct = [erps[i]['S_Correct incongr.'] for i in range(len(erps))]
    ga_sol_correct = mne.grand_average(sol_correct, drop_bads=False)

    pick = ga_neg_incorrect.ch_names.index('FCz')

    compare = plot_compare_evokeds(dict(neg_incorrect=ga_neg_incorrect,
                                        neg_correct=ga_neg_correct,
                                        pos_incorrect=ga_pos_incorrect,
                                        pos_correct=ga_pos_correct,
                                        solo_incorrect=ga_sol_incorrect,
                                        solo_correct=ga_sol_correct),
                                   picks=pick, ylim=dict(eeg=[9, -9]))

    topofig1 = ga_neg_incorrect.plot_topomap(times=np.arange(0, .12, .01),
                                             outlines='skirt')

    jointfig = ga_neg_incorrect.plot_joint(picks='eeg')


    jointfig.savefig("jointplot.png")
    topofig1.savefig("topofig1.png")
    compare.savefig("compare.png")
