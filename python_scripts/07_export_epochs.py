# ---  carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- EEG prepossessing - dpx-r40 [WIP]
# --- version march 2020 [WIP]

import mne
import re
import glob
import os
from mne import pick_types, Epochs, combine_evoked
import pandas as pd
import numpy as np

output_dir = '/Volumes/Recovery/ern_soc_eeg/derivatives/segmentation/epochs'
output_dir_ave = '/Volumes/Recovery/ern_soc_eeg/derivatives/segmentation/epochs/average'
data_path = '/Volumes/Recovery/ern_soc_eeg/derivatives/pruned'
for file in sorted(glob.glob(os.path.join(data_path, '*.fif'))):
    filepath, filename = os.path.split(file)
    filename, ext = os.path.splitext(filename)
    # Each time the loop goes through a new iteration,
    # add a subject integer to the data path
    data_path = '/Volumes/Recovery/ern_soc_eeg'
    subj = re.findall(r'\d+', filename)[0]
    # Read the raw EEG data that has been pre-processed, create an event file and down-sample the data for easier handling.
    raw = mne.io.read_raw_fif(file, preload=True)
    evs = mne.find_events(raw, stim_channel='Status', output='onset',
                          min_duration=0.002)
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
    # --- 4) PICK CHANNELS TO SAVE -----------------------------
    picks = pick_types(raw.info,
                       meg=False,
                       eeg=True,
                       eog=False,
                       stim=False)

    if int(subj) in {1002, 1004, 1006, 1008,
                     1010, 1011, 1013, 1015,
                     1017, 1019, 1021, 1023,
                     1028}:
        # set event ids
        choice_event_id = {'P_Correct congr.': 1091,
                           'P_Correct incongr.': 1092,
                           'P_Incorrect congr.': 1093,  # back to 1093
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

    # reject_criteria = dict(mag=4000e-15,  # 4000 fT
    #                        grad=4000e-13,  # 4000 fT/cm
    #                        eeg=150e-6,  # 150 μV
    #                        eog=250e-6)

    choice_epochs = Epochs(raw, new_evs, choice_event_id,
                           on_missing='ignore',
                           tmin=-1,
                           tmax=1,
                           baseline=(-.550, -.300),
                           reject_by_annotation=True,
                           preload=True,
                           picks=['FCz', 'Cz'])

    choice_epochs = choice_epochs.resample(sfreq=100, npad='auto')
    choice_epochs = choice_epochs.crop(tmin=.0, tmax=0.1)




    index, scaling_time, scalings = ['epoch', 'time'], 1e3, dict(grad=1e13)

    df = choice_epochs.to_data_frame(picks=None, scalings=scalings,
                                     scaling_time=scaling_time, index=index)


    df = df.reset_index()

    factors = ['condition', 'epoch']
    df = df.assign(subject=subj)
    df = pd.DataFrame(df)

    df.to_csv(os.path.join(output_dir, 'sub-%s.tsv' % subj),
              sep='\t',
              index=True)

    # fig = mne.viz.plot_events(new_evs, sfreq=raw.info['sfreq'])
    # ig.subplots_adjust(right=0.7)
