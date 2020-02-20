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
from os import mkdir
import os.path as op

import glob
import re

import numpy as np
import pandas as pd

from mne import events_from_annotations, pick_types, Epochs
from mne.io import read_raw_fif

# ========================================================================
# --- global settings
# prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if op.isdir(root_path):
    print('Setting "root_path" to ', root_path)
else:
    raise NameError('Directory not found!')

# path to eeg files
data_path = op.join(root_path, 'derivatives/pruned')
# output path
output_path = op.join(root_path, 'derivatives/epochs')
# path for saving epochs
# epochs_path = op.join(root_path, 'derivatives/epochs')

# create directory for save
if not op.isdir(op.join(output_path)):
    os.mkdir(op.join(output_path))

# files to be analysed
files = glob.glob(op.join(data_path, 'sub-*', '*-raw.fif'))

if not op.isdir(op.join(output_path)):
    mkdir(op.join(output_path))

# erps = []

# === LOOP THROUGH FILES AND EXTRACT EPOCHS =========================
for file in files:

    # --- 1) set up paths and file names -----------------------
    filepath, filename = os.path.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) Read in the data ----------------------------------
    raw = read_raw_fif(file, preload=True)

    # save sampling frequency
    sfreq = raw.info['sfreq']

    # --- 3) Create epochs metadata ----------------------------
    annotations = pd.DataFrame(raw.annotations)

    # create event dict
    # if description == 98 --> gray screen (non rewarded block)
    # if description == 99 --> green screen (rewarded block)
    event_id = {'113.0': 1,
                '112.0': 2,

                '13.0': 3,
                '12.0': 4,

                '70.0': 5,
                '71.0': 6,
                '72.0': 7,
                '73.0': 8,
                '74.0': 9,
                '75.0': 10,

                '76.0': 11,
                '77.0': 12,
                '78.0': 13,
                '79.0': 14,
                '80.0': 15,
                '81.0': 16,

                '98.0': 17,
                '99.0': 18,

                '245.0': 19}

    events = events_from_annotations(raw, event_id)

    new_evs = events[0]
    ids = events[1]

    trial = 0
    reaction = []
    rt = []
    weird = []

    block_rew = []
    block = []
    block_nr = 0

    # recode events
    for event in range(new_evs.shape[0]):

        # check which type of block we're in
        if new_evs[event, 2] == 18:
            reward = 1
            block_nr += 1
            continue
        elif new_evs[event, 2] == 17:
            reward = 0
            block_nr += 1
            continue

        # --- if event is a cue stimulus ---
        if new_evs[event, 2] in {5, 6, 7, 8, 9, 10}:
            block_rew.append(reward)
            block.append(block_nr)

            # --- 1st check: if next event is a false reaction ---
            if new_evs[event + 1, 2] in {1, 2}:
                # if event is an A-cue
                if new_evs[event, 2] == 5:
                    # recode as too soon A-cue
                    new_evs[event, 2] = 101
                # if event is a B-cue
                elif new_evs[event, 2] in {6, 7, 8, 9, 10}:
                    # recode as too soon B-cue
                    new_evs[event, 2] = 102

                # look for next probe
                i = 2
                while new_evs[event + i, 2] not in {11, 12, 13, 14, 15, 16}:
                    i += 1

                j = 2
                while new_evs[event + j, 2] not in {5, 6, 7, 8, 9, 10}:
                    j += 1

                # !!! something went wrong, check in array !!!
                # this is probably some weird presentation error in the experiment
                # usually probes should follow cues, but for some reason the experiment
                # dropped one probe and continue to the next trial.
                # perhaps a port-conflict because participant pressed button jus as the
                # probe was going to be presented??
                if j < i:
                    weird.append(trial)
                    continue

                # if probe is an X
                if new_evs[event + i, 2] == 11:
                    # recode as too soon X-probe
                    new_evs[event + i, 2] = 103
                # if probe is an Y
                else:
                    # recode as too soon Y-probe
                    new_evs[event + i, 2] = 104

                # save trial information as NaN
                trial += 1
                rt.append(np.nan)
                reaction.append(np.nan)
                # go on to next trial
                continue

            # --- 2nd check: if next event is a probe stimulus ---
            elif new_evs[event + 1, 2] in {11, 12, 13, 14, 15, 16}:

                # if event after probe is a reaction
                if new_evs[event + 2, 2] in {1, 2, 3, 4}:

                    # save reaction time
                    rt.append((new_evs[event + 2, 0] - new_evs[event + 1, 0]) / sfreq)

                    # if reaction is correct
                    if new_evs[event + 2, 2] in {3, 4}:

                        # save response
                        reaction.append(1)

                        # if cue was an A
                        if new_evs[event, 2] == 5:
                            # recode as correct A-cue
                            new_evs[event, 2] = 105

                            # if probe was an X
                            if new_evs[event + 1, 2] == 11:
                                # recode as correct AX probe combination
                                new_evs[event + 1, 2] = 106

                            # if probe was a Y
                            else:
                                # recode as correct AY probe combination
                                new_evs[event + 1, 2] = 107

                            # go on to next trial
                            trial += 1
                            continue

                        # if cue was a B
                        else:
                            # recode as correct B-cue
                            new_evs[event, 2] = 108

                            # if probe was an X
                            if new_evs[event + 1, 2] == 11:
                                # recode as correct BX probe combination
                                new_evs[event + 1, 2] = 109
                            # if probe was a Y
                            else:
                                # recode as correct BY probe combination
                                new_evs[event + 1, 2] = 110

                            # go on to next trial
                            trial += 1
                            continue

                    # if reaction was incorrect
                    else:

                        # save response
                        reaction.append(0)

                        # if cue was an A
                        if new_evs[event, 2] == 5:
                            # recode as incorrect A-cue
                            new_evs[event, 2] = 111

                            # if probe was an X
                            if new_evs[event + 1, 2] == 11:
                                # recode as incorrect AX probe combination
                                new_evs[event + 1, 2] = 112

                            # if probe was a Y
                            else:
                                # recode as incorrect AY probe combination
                                new_evs[event + 1, 2] = 113

                            # go on to next trial
                            trial += 1
                            continue

                        # if cue was a B
                        else:
                            # recode as incorrect B-cue
                            new_evs[event, 2] = 114

                            # if probe was an X
                            if new_evs[event + 1, 2] == 11:
                                # recode as incorrect BX probe combination
                                new_evs[event + 1, 2] = 115

                            # if probe was a Y
                            else:
                                # recode as incorrect BY probe combination
                                new_evs[event + 1, 2] = 116

                            # go on to next trial
                            trial += 1
                            continue

                # if no reaction followed cue-probe combination
                elif new_evs[event + 2, 2] not in {1, 2, 3, 4}:

                    # save reaction time as NaN
                    rt.append(99999)
                    reaction.append(np.nan)

                    # if cue was an A
                    if new_evs[event, 2] == 5:
                        # recode as missed A-cue
                        new_evs[event, 2] = 117

                        # if probe was an X
                        if new_evs[event + 1, 2] == 11:
                            # recode as missed AX probe combination
                            new_evs[event + 1, 2] = 118

                        # if probe was a Y
                        else:
                            # recode as missed AY probe combination
                            new_evs[event + 1, 2] = 119

                        # go on to next trial
                        trial += 1
                        continue

                    # if cue was a B
                    else:
                        # recode as missed B-cue
                        new_evs[event, 2] = 120

                        # if probe was an X
                        if new_evs[event + 1, 2] == 11:
                            # recode as missed BX probe combination
                            new_evs[event + 1, 2] = 121
                        # if probe was a Y
                        else:
                            # recode as missed BY probe combination
                            new_evs[event + 1, 2] = 122

                        # go on to next trial
                        trial += 1
                        continue

        # skip other events
        else:
            continue

    # --- 4) set event ids -------------------------------------
    # cue events
    cue_event_id = {'Too_soon A': 101,
                    'Too_soon B': 102,

                    'Correct A': 105,
                    'Correct B': 108,

                    'Incorrect A': 111,
                    'Incorrect B': 114,

                    'Missed A': 117,
                    'Missed B': 120}

    # probe events
    probe_event_id = {'Too_soon X': 103,
                      'Too_soon Y': 104,

                      'Correct AX': 106,
                      'Correct AY': 107,

                      'Correct BX': 109,
                      'Correct BY': 110,

                      'Incorrect AX': 112,
                      'Incorrect AY': 113,

                      'Incorrect BX': 115,
                      'Incorrect BY': 116,

                      'Missed AX': 118,
                      'Missed AY': 119,

                      'Missed BX': 121,
                      'Missed BY': 122}

    # reversed event_id dict
    cue_event_id_rev = {val: key for key, val in cue_event_id.items()}
    probe_event_id_rev = {val: key for key, val in probe_event_id.items()}

    # --- 5) create metadata -----------------------------------
    # save cue events
    cue_events = new_evs[np.where((new_evs[:, 2] == 101) |
                                  (new_evs[:, 2] == 102) |
                                  (new_evs[:, 2] == 105) |
                                  (new_evs[:, 2] == 108) |
                                  (new_evs[:, 2] == 111) |
                                  (new_evs[:, 2] == 114) |
                                  (new_evs[:, 2] == 117) |
                                  (new_evs[:, 2] == 120))]

    # save probe events
    probe_events = new_evs[np.where((new_evs[:, 2] == 103) |
                                    (new_evs[:, 2] == 104) |
                                    (new_evs[:, 2] == 106) |
                                    (new_evs[:, 2] == 107) |
                                    (new_evs[:, 2] == 109) |
                                    (new_evs[:, 2] == 110) |
                                    (new_evs[:, 2] == 112) |
                                    (new_evs[:, 2] == 113) |
                                    (new_evs[:, 2] == 115) |
                                    (new_evs[:, 2] == 116) |
                                    (new_evs[:, 2] == 118) |
                                    (new_evs[:, 2] == 119) |
                                    (new_evs[:, 2] == 121) |
                                    (new_evs[:, 2] == 122))]

    if len(cue_events) != len(probe_events):
        cue_events = np.delete(cue_events, weird, 0)
        block = np.delete(block, weird, 0)
        block_rew = np.delete(block_rew, weird, 0)

    # create list with reactions based on cue and probe event ids
    same_stim, reaction_cues, reaction_probes, cues, probes = [], [], [], [], []
    for cue, probe in zip(cue_events[:, 2], probe_events[:, 2]):
        response, cue = cue_event_id_rev[cue].split(' ')
        reaction_cues.append(response)
        # save cue
        cues.append(cue)

        # save response
        response, probe = probe_event_id_rev[probe].split(' ')
        reaction_probes.append(response)

        # check if same type of combination was shown in the previous trail
        if len(probes):
            stim = same_stim[-1]
            if probe == probes[-1] and response == 'Correct' and reaction_probes[-2] == 'Correct':
                stim += 1
                same_stim.append(stim)
            else:
                same_stim.append(0)
        else:
            stim = 0
            same_stim.append(0)

        # save probe
        probes.append(probe)

    # create metadata
    metadata = {'block': block,
                'reward': block_rew,
                'trial': range(0, trial),
                'cue': cues,
                'probe': probes,
                'run': same_stim,
                'reaction_cues': reaction_cues,
                'reaction_probes': reaction_probes,
                'rt': rt}
    # to data frame
    metadata = pd.DataFrame(metadata)

    # --- 6) extract epochs ------------------------------------
    # pick channels to keep
    picks = pick_types(raw.info, eeg=True)

    # rejection threshold
    reject = dict(eeg=150e-6)

    # create cue epochs
    cue_epochs = Epochs(raw, cue_events, cue_event_id,
                        metadata=metadata,
                        on_missing='ignore',
                        tmin=-2.,
                        tmax=2.5,
                        baseline=None,
                        preload=True,
                        reject_by_annotation=True,
                        picks=picks,
                        reject=reject,
                        proj=True
                        )

    # create probe epochs
    probe_epochs = Epochs(raw, probe_events, probe_event_id,
                          metadata=metadata,
                          on_missing='ignore',
                          tmin=-2.,
                          tmax=2.,
                          baseline=None,
                          preload=True,
                          reject_by_annotation=True,
                          picks=picks,
                          reject=reject,
                          proj=True
                          )

    # --- 7) save epochs info ------------------------------------
    # clean cue epochs
    clean_cues = cue_epochs.selection
    bad_cues = [x for x in set(list(range(0, trial)))
                if x not in set(cue_epochs.selection)]
    # clean probe epochs
    clean_probes = probe_epochs.selection
    bad_probes = [x for x in set(list(range(0, trial)))
                  if x not in set(probe_epochs.selection)]

    # --- 8) write summary ---------------------------------------
    # create directory for save
    if not op.exists(op.join(output_path, 'sub-%s' % subj)):
        mkdir(op.join(output_path, 'sub-%s' % subj))

    # write summary file
    name = op.join(output_path, 'sub-%s' % subj, 'sub-%s_epochs.txt' % subj)
    # open summary file
    sum_file = open(name, 'w')
    # summary of correct trials
    sum_file.write('correct_ax_epochs_are_' +
                   str(len(probe_epochs['Correct AX'])) + ':\n')
    sum_file.write('correct_ay_epochs_are_' +
                   str(len(probe_epochs['Correct AY'])) + ':\n')
    sum_file.write('correct_bx_epochs_are_' +
                   str(len(probe_epochs['Correct BX'])) + ':\n')
    sum_file.write('correct_by_epochs_are_' +
                   str(len(probe_epochs['Correct BY'])) + ':\n')
    # summary of kept and rejected segments
    sum_file.write('clean_cue_epochs_are_' + str(len(clean_cues)) + ':\n')
    for cue in clean_cues:
        sum_file.write('%s \n' % cue)

    sum_file.write('clean_probe_epochs_are_' + str(len(clean_probes)) + ':\n')
    for probe in clean_probes:
        sum_file.write('%s \n' % probe)

    sum_file.write('bad_cue_epochs_are_' + str(len(bad_cues)) + ':\n')
    for bad_cue in bad_cues:
        sum_file.write('%s \n' % bad_cue)

    sum_file.write('bad_probe_epochs_are_' + str(len(bad_probes)) + ':\n')
    for bad_probe in bad_probes:
        sum_file.write('%s \n' % bad_probe)
    # Close summary file
    sum_file.close()

    # --- 9) save epochs ---------------------------------------
    cue_epochs.save(op.join(output_path,
                            'sub-%s' % subj,
                            'sub-%s_cues-epo.fif' % subj),
                    overwrite=True)
    probe_epochs.save(op.join(output_path,
                              'sub-%s' % subj,
                              'sub-%s_probes-epo.fif' % subj),
                      overwrite=True)
