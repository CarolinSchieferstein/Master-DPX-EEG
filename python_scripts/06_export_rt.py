# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- eeg pre-processing for dpx-r40
# --- version: march 2020
#
# --- import data, crate info for file
# --- save to .fif

# ========================================================================
# ------------------- import relevant extensions -------------------------
from os import mkdir
import os.path as op
import glob
import re

from mne import read_epochs

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
data_path = op.join(root_path, 'derivatives/epochs')
# output path
output_path = op.join(root_path, 'derivatives/rt')

# create directory for save
if not op.isdir(op.join(output_path)):
    mkdir(op.join(output_path))

# files to be analysed

files = sorted(glob.glob(op.join(data_path, 'sub-*', '*cues-epo.fif')))

# === LOOP THROUGH FILES AND EXTRACT EPOCHS =========================
for file in files:
    # --- 1) set up paths and file names -----------------------
    filepath, filename = op.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) Read in the data ----------------------------------
    # import cue epochs
    cue_epochs = read_epochs(file, preload=True)

    # --- 3) Extract metadata ----------------------------------
    rt = cue_epochs.metadata

    # add subject id
    rt = rt.assign(subject=subj)

    # --- 4) Save file -----------------------------------------
    # create directory for save
    if not op.exists(op.join(output_path, 'sub-%s' % subj)):
        mkdir(op.join(output_path, 'sub-%s' % subj))

    # save to disk
    rt.to_csv(op.join(output_path, 'sub-%s' % subj,
                      'sub-%s-rt.tsv' % subj),
              sep='\t',
              index=False)
