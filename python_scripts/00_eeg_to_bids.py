# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- eeg pre-processing for DPX R40
# --- version: november 2019
#
# --- import data,
# --- convert to bids format

# ========================================================================
# ------------------- import relevant extensions -------------------------
import glob
import os
import re
from datetime import datetime

from pandas import read_csv

from mne.channels import make_standard_montage
from mne.io import read_raw_bdf
from mne import create_info, find_events

from mne_bids import write_raw_bids, make_bids_basename

# ========================================================================
# global settings
root_path = input("Type project path: ")  # prompt to set path

# look for directory
if os.path.isdir(root_path):
    print("Setting 'root_path' to ", root_path)
else:
    raise NameError('Directory not found!')

# input path
data_path = os.path.join(root_path, 'sourcedata/')

# path to subject demographics
subj_demo = os.path.join(root_path, 'subject_data/subject_demographics.tsv')

# files to be analysed
files = sorted(glob.glob(os.path.join(data_path, 'sub-*', '*.bdf')))

# subjects data
subj_demo = read_csv(subj_demo, sep='\t', header=0)

# define further variables that apply to all files in the data set
task = 'dpxr40'
task_description = 'DPX-R40, effects of reward and personality'
# eeg channel names and locations
montage = make_standard_montage(kind='standard_1020')

# channels to be exclude from import
exclude = ['EXG5', 'EXG6', 'EXG7', 'EXG8']

# ========================================================================
# --------- loop through files and make bids-files blocks  ---------------
for ind, file in enumerate(files):

    # --- 1) set up paths and file names -----------------------
    filepath, filename = os.path.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0].rjust(3, '0')

    # --- 2) import the data -----------------------------------
    raw = read_raw_bdf(file,
                       preload=False,
                       exclude=exclude)

    # --- 3) dataset info --------------------------------------
    # keep the sampling rate
    sfreq = raw.info['sfreq']
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

    # --- 4) add subject specific information -------------------
    # create tuple containing approx. birthday
    date_of_record = raw.annotations.orig_time
    # unix timestap to date
    date = datetime.utcfromtimestamp(date_of_record).strftime('%Y-%m-%d')
    # compute approx. date of birth
    year_of_birth = int(date.split('-')[0]) - subj_demo.iloc[ind].age
    approx_birthday = (year_of_birth,
                       int(date[5:].split('-')[0]),
                       int(date[5:].split('-')[1]))
    # add subject info to dataset info
    raw.info['subject_info'] = dict(id=int(subj),
                                    sex=subj_demo.iloc[ind].sex,
                                    birthday=approx_birthday)

    # --- 4) events info ---------------------------------------
    # extract events
    events = find_events(raw,
                         stim_channel='Status',
                         output='onset',
                         min_duration=0.002)

    # event ids
    events_id = {'correct_target_button': 13,
                 'correct_non_target_button': 12,
                 'incorrect_target_button': 113,
                 'incorrect_non_target_button': 112,
                 'cue_0': 70,
                 'cue_1': 71,
                 'cue_2': 72,
                 'cue_3': 73,
                 'cue_4': 74,
                 'cue_5': 75,
                 'probe_0': 76,
                 'probe_1': 77,
                 'probe_2': 78,
                 'probe_3': 79,
                 'probe_4': 80,
                 'probe_5': 81,
                 'feedback_hit': 85,
                 'feedback_incorrect': 86,
                 'block_nr': 98,
                 'block_r': 99,
                 'start': 127,
                 'stopp': 255}

    # --- 5) export to bids ------------------------------------
    # file name compliant with bids
    bids_basename = make_bids_basename(
        subject=subj,
        task=task)

    # save in bids format
    write_raw_bids(raw,
                   bids_basename,
                   root_path,
                   event_id=events_id,
                   events_data=events,
                   overwrite=True)
