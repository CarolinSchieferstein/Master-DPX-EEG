# --- carolin schieferstein
# --- utf-8
# --- Python 3.7.3 / mne 0.18.1
#
# --- eeg pre-processing for DPX R40
# --- version: november 2019
#
# --- import data, drop flat channels,
# --- extract task blocks

# ========================================================================
# ------------------- import relevant extensions -------------------------
import glob
import os.path as op
from os import mkdir

import re
import numpy as np
import pandas as pd

from mne import create_info, find_events, Annotations, \
    events_from_annotations
from mne.io import read_raw_bdf
from mne.channels import make_standard_montage

# ========================================================================
# --- global settings
# --- prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if op.isdir(root_path):
    print("Setting 'root_path' to ", root_path)
else:
    raise NameError('Directory not found!')

# path to eeg files
data_path = op.join(root_path, 'sub-*')

# path for saving output
derivatives_path = op.join(root_path, 'derivatives')

# create directory for derivatives
if not op.isdir(derivatives_path):
    mkdir(derivatives_path)
    mkdir(op.join(derivatives_path, 'extract_blocks'))

# path for saving script output
output_path = op.join(derivatives_path, 'extract_blocks')

# files to be analysed
files = sorted(glob.glob(op.join(data_path, 'eeg/*.bdf')))

# ========================================================================
# -- define further variables that apply to all files in the data set
task_description = 'DPX, effects of reward and personality'
# eeg channel names and locations
montage = make_standard_montage(kind='standard_1020')
# channels to be exclude from import
exclude = ['EXG5', 'EXG6', 'EXG7', 'EXG8']

# ========================================================================
# ------------ loop through files and extract blocks  --------------------
for file in files:

    # --- 1) set up paths and file names -----------------------
    filepath, filename = op.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0].rjust(3, '0')
    print(subj)

    # --- 2) import the data -----------------------------------
    raw = read_raw_bdf(file,
                       preload=True,
                       exclude=exclude)

    # check data and remove channel with low (i.e., near zero variance)
    flats = np.where(np.std(raw.get_data(), axis=1) * 1e6 < 10.)[0]
    # names
    flats = [raw.ch_names[ch] for ch in flats]
    # print summary
    print('Following channels were dropped as variance ~ 0:', flats)
    # remove them from data set
    raw.drop_channels(flats)

    # --- 3) modify data set information  ----------------------
    # keep the sampling rate
    sfreq = raw.info['sfreq']
    # and date of measurement
    date_of_record = raw.annotations.orig_time

    # all channels in raw
    chans = raw.info['ch_names']
    # channels in montage
    montage_chans = montage.ch_names
    # nr of eeg channels
    n_eeg = len([chan for chan in chans if chan in montage_chans])
    # channel types
    types = []
    for chan in chans:
        if chan in montage_chans:
            types.append('eeg')
        elif re.match('EOG|EXG', chan):
            types.append('eog')
        else:
            types.append('stim')

    # create custom info for subj file
    info_custom = create_info(chans, sfreq, types, montage)
    # description / name of experiment
    info_custom['description'] = task_description
    # overwrite file info
    raw.info = info_custom
    # replace date info
    raw.info['meas_date'] = date_of_record

    # --- 3) set reference to remove residual line noise  ------
    raw.set_eeg_reference(['Cz'], projection=False)

    # --- 5) find cue events in data ---------------------------
    # get events
    events = find_events(raw,
                         stim_channel='Status',
                         output='onset',
                         min_duration=0.002)

    # discard edge events
    events = events[(events[:, 2] <= 245)]

    # events tp pandas data frame
    annot_infos = ['onset', 'duration', 'description']
    evs = pd.DataFrame(events, columns=annot_infos, dtype=np.float)
    evs.onset = (evs.onset / sfreq)

    # crate annotations object
    annotations = Annotations(evs['onset'],
                              evs['duration'],
                              evs['description'],
                              orig_time=date_of_record)
    # apply to raw data
    raw.set_annotations(annotations)

    # drop stimulus channel
    raw.drop_channels('Status')

    # --- 6) find block start ----------------------------------
    blocks = events[(events[:, 2] == 98) | (events[:, 2] == 99), 0]
    latencies = (blocks / sfreq)

    # --- 7) extract block data --------------------------------
    # Block 1
    raw_bl = raw.copy().crop(tmin=latencies[0])

    # --- 8) lower the sample rate  ---------------------------
    raw_bl.resample(sfreq=256.)

    # --- 12) save segmented data  -----------------------------
    # create directory for save
    if not op.exists(op.join(output_path, 'sub-%s' % subj)):
        mkdir(op.join(output_path, 'sub-%s' % subj))

    # save file
    raw_bl.save(op.join(output_path, 'sub-' + str(subj),
                        'sub-%s_task_blocks-raw.fif' % subj),
                overwrite=True)

    # --- 13) save script summary  ------------------------------
    # get cue events in segmented data
    events = events_from_annotations(raw_bl, regexp='^[7][0-5]')[0]

    # number of trials
    nr_trials = len(events)

    # write summary
    name = 'sub-%s_task_blocks_summary.txt' % subj
    sfile = open(op.join(output_path, 'sub-%s', name) % subj, 'w')
    # block info
    sfile.write('Block_from:\n%s to %s\n' % (str(round(latencies[0], 2)),
                                             str(round(latencies[-1], 2))))
    sfile.write('Block_length:\n%s\n' % round(latencies[-1] - latencies[0], 2))
    # number of trials in file
    sfile.write('number_of_trials_found:\n%s\n' % nr_trials)
    # channels dropped
    sfile.write('channels_with_zero_variance:\n')
    for ch in flats:
        sfile.write('%s\n' % ch)
    sfile.close()

    del raw, raw_bl
